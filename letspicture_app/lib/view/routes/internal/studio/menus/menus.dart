import 'package:flutter/material.dart';
import 'package:letspicture_app/storage/project/project_model.dart';
import 'package:letspicture_app/view/routes/internal/studio/menus/top/top_menu.dart';

import '../studio_route.dart';
import 'bottom/bottom_menu.dart';

class StudioMenus extends StatelessWidget {
  final StudioScreenMode screenMode;
  final ValueChanged<StudioScreenMode> updateScreenMode;
  final bool isReady;
  final Project project;

  const StudioMenus(
      {Key key,
      this.screenMode,
      this.updateScreenMode,
      this.isReady,
      this.project})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        StudioTopMenu(
          screenMode: screenMode,
          updateScreenMode: updateScreenMode,
          isReady: isReady,
          project: project,
        ),
        AdjustmentsMenu(
          screenMode: screenMode,
          updateScreenMode: updateScreenMode,
          isReady: isReady,
          project: project,
        )
      ],
    );
  }
}
