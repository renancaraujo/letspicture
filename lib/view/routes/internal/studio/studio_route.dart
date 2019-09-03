import 'package:flutter/material.dart';
import 'package:letspicture/config/application.dart';
import 'package:fluro/fluro.dart';
import 'package:letspicture/editor/editor.dart';
import 'package:letspicture/storage/observables/project.dart';
import 'package:letspicture/storage/observables/project_collection.dart';
import 'package:letspicture/storage/project/project_file.dart';

import 'back/export_menu.dart';
import 'image/image_wrapper.dart';
import 'menus/menus.dart';

class StudioRoute extends RouteWidget {
  StudioRoute() : super("/studio", transitionType: TransitionType.fadeIn);

  @override
  Widget build(BuildContext context, Map<String, List<String>> parameters) {
    final String id = parameters["projectId"][0];

    final ProjectObservable projectObservable =
        projectCollectionObservable.getById(int.parse(id));
    return StudioScreen(projectObservable);
  }
}

enum StudioScreenMode { normal, focusedMode, exporting }

class StudioScreen extends StatefulWidget {
  StudioScreen(this.projectObservable);

  final ProjectObservable projectObservable;

  @override
  _StudioScreenState createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  bool isReady;
  ProjectOriginalBitmapFile imageFile;
  StudioScreenMode screenMode = StudioScreenMode.normal;
  bool loading = false;

  void changeScreenMode(StudioScreenMode screenMode) {
    setState(() {
      this.screenMode = screenMode;
    });
  }

  void setLoading(bool to) {
    setState(() {
      loading = to;
    });
  }

  @override
  void initState() {
    super.initState();
    isReady = true;

    if (widget.projectObservable.value.originalBitmapFile == null) {
      _loadImageFile();
    } else {
      isReady = false;
    }

    makeReady();
  }

  void makeReady() async {
    final futures = <Future>[
      Future.delayed(const Duration(milliseconds: 400)),
      Editor.instance.mountNiks(widget.projectObservable),
    ];
    await Future.wait(futures);
    if (!mounted) {
      return;
    }
    setState(() {
      isReady = true;
    });
  }

  @override
  void dispose() {
    super.dispose();

    Editor.instance.unmountNiks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        StudioExportMenu(
            project: widget.projectObservable.value,
            isReady: isReady,
            screenMode: screenMode,
            updateScreenMode: changeScreenMode,
            setScreenLoading: setLoading),
        ImageWrapper(
          project: widget.projectObservable.value,
          isReady: isReady,
          screenMode: screenMode,
          updateScreenMode: changeScreenMode,
        ),
        StudioMenus(
          project: widget.projectObservable.value,
          screenMode: screenMode,
          updateScreenMode: changeScreenMode,
          isReady: isReady,
        ),
        loading
            ? Positioned.fill(
                child: Container(
                decoration: BoxDecoration(color: Colors.black.withAlpha(220)),
                child: Center(
                  child: const CircularProgressIndicator(),
                ),
              ))
            : Container()
      ],
    ));
  }

  void _loadImageFile() async {
    isReady = false;
  }
}
