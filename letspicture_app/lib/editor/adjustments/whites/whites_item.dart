import 'package:flutter/material.dart';
import 'package:niks/layer_types/bitmap/filters/adjust_color.dart';

import '../../editor.dart';
import '../adjustments_items.dart';
import 'whites_subject.dart';

class WhitesMenuItem extends AdjustmentsMenuItem {
  WhitesMenuItem()
      : super(
            "Whites",
            Image.asset(
              "assets/icons/editor/whites.png",
              width: iconWidth,
            ));

  @override
  Widget itemBuilder(BuildContext context) {
    return Container(
      child: WhitesItemEditor(),
    );
  }
}

class WhitesItemEditor extends StatefulWidget {
  @override
  _WhitesItemEditorState createState() => _WhitesItemEditorState();
}

class _WhitesItemEditorState extends State<WhitesItemEditor> {
  WhitesSubjectManager subjectManager;

  AdjustColorFilter get filter => Editor.instance.adjustColorFilter;

  @override
  void initState() {
    super.initState();

    subjectManager = WhitesSubjectManager();
    subjectManager.add(subjectManager.convertToIn(filter.whites));

    subjectManager.outcomes.listen(onData);
  }

  @override
  void dispose() {
    subjectManager.dispose();
    super.dispose();
  }

  void onData(int event) {
    filter.whites = event;
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
            value: subjectManager.value ?? 255.0,
            min: 0.0,
            max: 255.0,
            onChanged: onChanged);
      },
    );
  }
}
