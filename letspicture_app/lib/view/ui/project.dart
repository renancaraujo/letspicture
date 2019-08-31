import 'package:flutter/material.dart';
import 'package:letspicture_app/storage/project/project_model.dart';

class ProjectThumbnail extends StatefulWidget {
  final Project letsPictureProject;

  const ProjectThumbnail({Key key, this.letsPictureProject}) : super(key: key);

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
