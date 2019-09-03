import 'package:flutter/material.dart';
import 'package:niks_bitmap/niks_bitmap.dart';

import '../../editor.dart';
import '../adjustments_items.dart';
import 'brightness_subject.dart';

class BrightnessMenuItem extends AdjustmentsMenuItem {
  BrightnessMenuItem()
      : super(
            "Brightness",
            Image.asset("assets/icons/editor/brightness.png",
                width: iconWidth));

  @override
  Widget itemBuilder(BuildContext context) {
    return Container(
      child: BrightnessItemEditor(),
    );
  }
}

class BrightnessItemEditor extends StatefulWidget {
  @override
  _BrightnessItemEditorState createState() => _BrightnessItemEditorState();
}

class _BrightnessItemEditorState extends State<BrightnessItemEditor> {
  BrightnessSubjectManager subjectManager;

  BrightnessFilter get filter => Editor.instance.brightnessFilter;

  @override
  void initState() {
    super.initState();

    subjectManager = BrightnessSubjectManager();
    subjectManager.add(subjectManager.convertToIn(filter.brightnessRate));

    subjectManager.outcomes.listen(onData);
  }

  @override
  void dispose() {
    super.dispose();
    subjectManager.dispose();
  }

  void onData(double event) {
    filter.brightnessRate = event;
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
