import 'package:flutter/widgets.dart';
import 'package:letspicture/editor/editor.dart';
import 'package:letspicture/storage/project/project_model.dart';
import 'package:niks/niks_flutter.dart';

class InnerNiks extends StatelessWidget {
  const InnerNiks({Key key, this.project}) : super(key: key);

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: project.imageSize.width,
      height: project.imageSize.height,
      child: NiksRenderWidget(Editor.instance.skin),
    );
  }
}
