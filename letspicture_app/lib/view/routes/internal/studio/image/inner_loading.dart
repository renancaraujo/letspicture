import 'package:flutter/material.dart';
import 'package:letspicture_app/storage/project/project_model.dart';
import 'package:letspicture_app/view/ui/animated.dart';

class InnerLoading extends StatelessWidget {
  final Project project;

  const InnerLoading({Key key, this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.lightGreenAccent),
      child: Stack(
        children: <Widget>[
          Image.memory(
            project.thumbnailFile.fileData,
            width: project.imageSize.width,
            height: project.imageSize.height,
            fit: BoxFit.fill,
          ),
          Positioned.fill(
              child: Opacity(
            opacity: 0.4,
            child: BorderLoader(
              size: project.imageSize,
            ),
          ))
        ],
      ),
    );

    // Image.memory(project.previewFile.fileData)
  }
}
