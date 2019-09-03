import 'package:flutter/material.dart';
import 'package:letspicture/editor/exporter.dart';
import 'package:letspicture/storage/project/project_model.dart';

import '../studio_route.dart';

class StudioExportMenu extends StatelessWidget {
  const StudioExportMenu({
    Key key,
    this.project,
    this.isReady,
    this.screenMode,
    this.updateScreenMode,
    this.setScreenLoading,
  }) : super(key: key);

  final Project project;
  final bool isReady;
  final StudioScreenMode screenMode;
  final ValueChanged<StudioScreenMode> updateScreenMode;
  final ValueChanged<bool> setScreenLoading;

  bool get showing => screenMode == StudioScreenMode.exporting;

  Function onExport(ExportConfig config) => () async {
        setScreenLoading(true);
        await Exporter.saveImageToGallery(config, project);
        setScreenLoading(false);
        updateScreenMode(StudioScreenMode.normal);
      };

  @override
  Widget build(BuildContext context) {
    const duration = const Duration(milliseconds: 550);
    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AnimatedOpacity(
            duration: duration,
            curve: Curves.easeOutCubic,
            opacity: showing ? 1.0 : 0.0,
            child: Container(
              width: MediaQuery.of(context).size.width - 150,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: <Color>[
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.1),
                ],
              )),
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()
                  ..translate(showing ? 0.0 : -50.0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildButtons(context),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    final ommitFast = project.imageSize == project.thumbnailSize;
    final ommitMini = project.miniSize == project.thumbnailSize ||
        true; // mini not implemnented
    return <Widget>[
      ExportButton(
        identifier: "Original",
        imageSize: project.imageSize,
        onPressed: onExport(ExportConfig.original),
      ),
      (ommitFast
          ? Container()
          : ExportButton(
              identifier: "Fast",
              imageSize: project.thumbnailSize,
              onPressed: onExport(ExportConfig.fast),
            )),
      (ommitMini
          ? Container()
          : ExportButton(
              identifier: "Mini",
              imageSize: project.miniSize,
              onPressed: onExport(ExportConfig.mini),
            )),
    ];
  }
}

class ExportButton extends StatelessWidget {
  const ExportButton({Key key, this.identifier, this.imageSize, this.onPressed})
      : super(key: key);

  final String identifier;
  final Size imageSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return FlatButton(
            onPressed: onPressed,
            padding: const EdgeInsets.all(0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              width: constraints.maxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    identifier,
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    "${imageSize.width.floor()}x${imageSize.height.floor()}",
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF898989),
                    ),
                  )
                ],
              ),
            ));
      },
    );
  }
}
