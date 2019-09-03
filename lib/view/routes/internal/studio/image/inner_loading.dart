import 'package:flutter/material.dart';
import 'package:letspicture/storage/project/project_model.dart';
import 'package:letspicture/view/ui/animated.dart';

class InnerLoading extends StatelessWidget {
  const InnerLoading({Key key, this.project}) : super(key: key);

  final Project project;

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
            ),
          )
        ],
      ),
    );

    // Image.memory(project.previewFile.fileData)
  }
}
