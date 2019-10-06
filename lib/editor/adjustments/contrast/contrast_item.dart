import 'package:flutter/material.dart';
import 'package:niks_bitmap/niks_bitmap.dart';

import '../../editor.dart';
import '../adjustments_items.dart';
import 'contrast_subject.dart';

class ContrastAdjustmentMenuItem extends AdjustmentsMenuItemWidget {
  ContrastAdjustmentMenuItem()
      : super(
          "Contrast",
          Image.asset(
            "assets/icons/editor/contrast.png",
            width: iconWidth,
          ),
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ContrastSlider(),
    );
  }
}

class ContrastSlider extends StatefulWidget {
  @override
  _ContrastSliderState createState() => _ContrastSliderState();
}

class _ContrastSliderState extends State<ContrastSlider> {
  ContrastSubjectManager subjectManager;

  ContrastFilter get filter => Editor.instance.contrastFilter;

  @override
  void initState() {
    super.initState();

    subjectManager = ContrastSubjectManager();
    subjectManager.sink(subjectManager.convertToIn(filter.contrastRate));

    subjectManager.outcomes.listen(onData);
  }

  @override
  void dispose() {
    subjectManager.dispose();
    super.dispose();
  }

  void onData(double event) {
    filter.contrastRate = event;
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
          max: 1.0,
          onChanged: onChanged,
        );
      },
    );
  }
}
