import 'package:flutter/material.dart';
import 'package:niks_bitmap/filters/adjust_color.dart';

import '../../editor.dart';
import '../adjustments_items.dart';
import 'exposure_subject.dart';

class ExposureMenuItem extends AdjustmentsMenuItemWidget {
  ExposureMenuItem()
      : super(
            "Exposure",
            Image.asset(
              "assets/icons/editor/exposure.png",
              width: iconWidth,
            ));

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ExposureItemEditor(),
    );
  }
}

class ExposureItemEditor extends StatefulWidget {
  @override
  _ExposureItemEditorState createState() => _ExposureItemEditorState();
}

class _ExposureItemEditorState extends State<ExposureItemEditor> {
  ExposureSubjectManager subjectManager;

  AdjustColorFilter get filter => Editor.instance.adjustColorFilter;

  @override
  void initState() {
    super.initState();

    subjectManager = ExposureSubjectManager();
    subjectManager.sink(subjectManager.convertToIn(filter.exposure));

    subjectManager.outcomes.listen(onData);
  }

  @override
  void dispose() {
    subjectManager.dispose();
    super.dispose();
  }

  void onData(double event) {
    filter.exposure = event;
  }

  void onChanged(double value) {
    subjectManager.sink(value);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: subjectManager.subject,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        return Slider(
          value: subjectManager.value ?? 0.0,
          min: -1.0,
          max: 2.5,
          onChanged: onChanged,
        );
      },
    );
  }
}
