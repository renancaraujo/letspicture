import 'package:flutter/widgets.dart';
import 'package:letspicture_app/editor/editor.dart';
import 'package:letspicture_app/storage/project/project_model.dart';
import 'package:niks/niks_flutter.dart';

class InnerNiks extends StatelessWidget {
  final Project project;

  const InnerNiks({Key key, this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: project.imageSize.width,
      height: project.imageSize.height,
      child: NiksRenderWidget(Editor.instance.skin),
    );

    // Image.memory(project.previewFile.fileData)
  }
}
