import 'package:flutter/material.dart';
import 'package:niks_bitmap/niks_bitmap.dart';

import '../../editor.dart';
import '../adjustments_items.dart';
import 'blacks_subject.dart';

class BlacksMenuItem extends AdjustmentsMenuItem {
  BlacksMenuItem()
      : super(
            "Blacks",
            Image.asset(
              "assets/icons/editor/blacks.png",
              width: iconWidth,
            ));

  @override
  Widget itemBuilder(BuildContext context) {
    return Container(
      child: BlacksItemEditor(),
    );
  }
}

class BlacksItemEditor extends StatefulWidget {
  @override
  _BlacksItemEditorState createState() => _BlacksItemEditorState();
}

class _BlacksItemEditorState extends State<BlacksItemEditor> {
  BlacksSubjectManager subjectManager;

  AdjustColorFilter get filter => Editor.instance.adjustColorFilter;

  @override
  void initState() {
    super.initState();

    subjectManager = BlacksSubjectManager();
    subjectManager.add(subjectManager.convertToIn(filter.blacks));

    subjectManager.outcomes.listen(onData);
  }

  @override
  void dispose() {
    subjectManager.dispose();
    super.dispose();
  }

  void onData(int event) {
    filter.blacks = event;
  }

  void onChanged(double value) {
    subjectManager.add(value);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: subjectManager.subject,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        return Slider(
            value: subjectManager.value ?? 0.0,
            min: 0.0,
            max: 255.0,
            onChanged: onChanged);
      },
    );
  }
}
