import 'package:flutter/material.dart';
import 'package:niks_bitmap/niks_bitmap.dart';

import '../../editor.dart';
import '../adjustments_items.dart';
import 'contrast_subject.dart';

class ContrastMenuItem extends AdjustmentsMenuItem {
  ContrastMenuItem()
      : super("Contrast",
            Image.asset("assets/icons/editor/contrast.png", width: iconWidth));

  @override
  Widget itemBuilder(BuildContext context) {
    return Container(
      child: ContrastItemEditor(),
    );
  }
}

class ContrastItemEditor extends StatefulWidget {
  @override
  _ContrastItemEditorState createState() => _ContrastItemEditorState();
}

class _ContrastItemEditorState extends State<ContrastItemEditor> {
  ContrastSubjectManager subjectManager;

  ContrastFilter get filter => Editor.instance.contrastFilter;

  @override
  void initState() {
    super.initState();

    subjectManager = ContrastSubjectManager();
    subjectManager.add(subjectManager.convertToIn(filter.contrastRate));

    subjectManager.outcomes.listen(onData);
  }

  @override
  void dispose() {
    subjectManager.dispose();
    super.dispose();
  }

  void onData(double event) {
    print(event);
    filter.contrastRate = event;
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
            min: -1.0,
            max: 1.0,
            onChanged: onChanged);
      },
    );
  }
}
