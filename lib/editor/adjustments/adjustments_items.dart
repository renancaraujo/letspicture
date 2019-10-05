import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'blacks/blacks_item.dart';
import 'brightness/brightness_item.dart';
import 'contrast/contrast_item.dart';
import 'exposure/exposure_item.dart';
import 'saturation/saturation_item.dart';
import 'whites/whites_item.dart';

typedef MenuOptionBuilder = Widget Function(BuildContext context);

const double iconWidth = 25;

final List<AdjustmentsMenuItem> adjustmentsMenuItems = <AdjustmentsMenuItem>[
  ContrastMenuItem(),
  BrightnessMenuItem(),
  SaturationMenuItem(),
  BlacksMenuItem(),
  WhitesMenuItem(),
  ExposureMenuItem(),
];

abstract class AdjustmentsMenuItem {
  AdjustmentsMenuItem(this.title, this.icon);

  final String title;
  final Image icon;

  Widget itemBuilder(BuildContext context);
}

class OptionEditor extends StatelessWidget {
  const OptionEditor({Key key, @required this.option, @required this.onBack})
      : assert(option != null),
        assert(onBack != null),
        super(key: key);

  final AdjustmentsMenuItem option;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GestureDetector(
              onTap: onBack,
              child: Container(
                decoration: BoxDecoration(color: Colors.transparent),
                padding: const EdgeInsets.only(
                  top: 30.0,
                  bottom: 10.0,
                  left: 10.0,
                  right: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.chevron_left),
                    Text(
                      option.title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white, thumbColor: Colors.white),
                child: option.itemBuilder(context),
              ),
            ),
          ],
        ));
  }
}

abstract class ItemSubjectManager<InType, OutType> {
  ItemSubjectManager() : subject = BehaviorSubject<InType>() {
    outcomes = subject
        .throttleTime(const Duration(milliseconds: 100), trailing: true)
        .map<OutType>(convertToOut);
    subject.listen((InType newValue) => value = newValue);
  }

  InType value;
  BehaviorSubject<InType> subject;
  Observable<OutType> outcomes;

  void dispose() {
    subject.close();
  }

  void add(InType event) {
    subject.add(event);
  }

  InType convertToIn(OutType outValue);
  OutType convertToOut(InType inValue);
}
