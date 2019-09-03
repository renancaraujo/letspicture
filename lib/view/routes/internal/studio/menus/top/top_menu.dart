import 'package:flutter/material.dart';
import 'package:letspicture/config/application.dart';
import 'package:letspicture/storage/project/project_model.dart';
import 'package:letspicture/view/ui/gradients.dart';

import '../../studio_route.dart';

class StudioTopMenu extends StatelessWidget {
  const StudioTopMenu(
      {Key key,
      this.screenMode,
      this.updateScreenMode,
      this.isReady,
      this.project})
      : super(key: key);

  final StudioScreenMode screenMode;
  final ValueChanged<StudioScreenMode> updateScreenMode;
  final bool isReady;
  final Project project;

  bool get showing {
    if (!isReady) {
      return false;
    }
    return screenMode == StudioScreenMode.focusedMode ? false : true;
  }

  double get opacity => showing ? 1.0 : 0.0;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      opacity: opacity,
      child: Stack(
        children: <Widget>[
          MenuBackdrop(
            screenMode: screenMode,
            updateScreenMode: updateScreenMode,
          ),
          TopMenuItems(
              screenMode: screenMode,
              updateScreenMode: updateScreenMode,
              isReady: isReady,
              project: project,
              showing: showing)
        ],
      ),
    ));
  }
}

class MenuBackdrop extends StatelessWidget {
  const MenuBackdrop({Key key, this.screenMode, this.updateScreenMode})
      : super(key: key);

  final StudioScreenMode screenMode;
  final ValueChanged<StudioScreenMode> updateScreenMode;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        child: Container(
      child: CustomPaint(
        painter: MenuGradientPainter(
            fadeLength: 200,
            radiusMultiplier: 1.0 + 10 / MediaQuery.of(context).size.height,
            center: const Alignment(0.0, 1.05)),
        child: Container(),
      ),
    ));
  }
}

class TopMenuItems extends StatelessWidget {
  const TopMenuItems(
      {Key key,
      this.isReady,
      this.screenMode,
      this.updateScreenMode,
      this.project,
      this.showing})
      : super(key: key);
  final StudioScreenMode screenMode;
  final ValueChanged<StudioScreenMode> updateScreenMode;
  final bool isReady;
  final Project project;
  final bool showing;

  Future<bool> onWillPop() async {
    if (screenMode == StudioScreenMode.exporting) {
      updateScreenMode(StudioScreenMode.normal);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        child: IgnorePointer(
            ignoring: !showing,
            child: SafeArea(
                child: Container(
                    height: 75,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FlatButton(
                            onPressed: () {
                              if (screenMode == StudioScreenMode.exporting) {
                                return updateScreenMode(
                                    StudioScreenMode.normal);
                              }
                              Application.instance.router.pop(context);
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.chevron_left),
                                Text(
                                  "Back",
                                  style: TextStyle(fontSize: 18),
                                )
                              ],
                            )),
                        _buildExporButton(context),
                      ],
                    )))));
  }

  Widget _buildExporButton(BuildContext context) {
    return WillPopScope(
        onWillPop: onWillPop,
        child: FlatButton(
            onPressed: () {
              updateScreenMode(StudioScreenMode.exporting);
            },
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              "Export",
              style: TextStyle(fontSize: 18),
            )));
  }
}
