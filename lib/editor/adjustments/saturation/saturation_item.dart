import 'package:flutter/material.dart';
import 'package:niks_bitmap/filters/adjust_color.dart';

import '../../editor.dart';
import '../adjustments_items.dart';
import 'saturation_subject.dart';

class SaturationMenuItem extends AdjustmentsMenuItem {
  SaturationMenuItem()
      : super(
            "Saturation",
            Image.asset(
              "assets/icons/editor/saturation.png",
              width: iconWidth,
            ));

  @override
  Widget itemBuilder(BuildContext context) {
    return Container(
      child: SaturationItemEditor(),
    );
  }
}

class SaturationItemEditor extends StatefulWidget {
  @override
  _SaturationItemEditorState createState() => _SaturationItemEditorState();
}

class _SaturationItemEditorState extends State<SaturationItemEditor> {
  SaturationSubjectManager subjectManager;

  AdjustColorFilter get filter => Editor.instance.adjustColorFilter;

  @override
  void initState() {
    super.initState();

    subjectManager = SaturationSubjectManager();
    subjectManager.add(subjectManager.convertToIn(filter.saturation));

    subjectManager.outcomes.listen(onData);
  }

  @override
  void dispose() {
    subjectManager.dispose();
    super.dispose();
  }

  void onData(double event) {
    filter.saturation = event;
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
