import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:letspicture_app/storage/managers/projects.dart';

import 'package:letspicture_app/config/typedefs.dart';

import 'dart:math' as math;
import 'package:letspicture_app/storage/observables/project.dart';
import 'package:letspicture_app/view/routes/internal/summary/slide_delete.dart';

class SummaryImageThumb extends StatelessWidget {
  const SummaryImageThumb(this.projectObservable,
      {Key key,
      @required this.showDeletePrompt,
      @required this.onPrompt,
      @required this.onCancelPrompt})
      : super(key: key);

  final ProjectObservable projectObservable;
  final bool showDeletePrompt;
  final IntCallback onPrompt;
  final VoidCallback onCancelPrompt;

  Future<void> onDelete(int id) async {
    await ProjectsManager.deleteProject(projectObservable.value);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = projectObservable.value.imageSize;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final double maxWidth = math.min(constraints.maxWidth - 20, 300);
      final double finalHeight = (maxWidth / size.width) * size.height;
      final Size imageSize = Size(maxWidth, finalHeight);

      return Observer(
        builder: (BuildContext context) {
          return SlideToDelete(
            project: projectObservable.value,
            showDeletePrompt: showDeletePrompt,
            onDelete: onDelete,
            size: imageSize,
            onPrompt: onPrompt,
            onCancelPrompt: onCancelPrompt,
            outBounds: constraints.maxWidth,
          );
        },
      );
    });
  }
}
