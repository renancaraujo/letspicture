import 'package:flutter/material.dart';
import 'package:letspicture/storage/project/project_model.dart';

class ProjectThumbnail extends StatefulWidget {
  const ProjectThumbnail({Key key, this.letsPictureProject}) : super(key: key);

  final Project letsPictureProject;

  @override
  _ProjectThumbnailState createState() => _ProjectThumbnailState();
}

class _ProjectThumbnailState extends State<ProjectThumbnail> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: Stack(
          children: <Widget>[
            Center(
              child: Hero(
                  tag: widget.letsPictureProject,
                  child: Image(
                    image: null, //widget.letsPictureProject.imageProvider,
                    width: 300,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
