import '../adjustments_items.dart';

class BrightnessSubjectManager extends ItemSubjectManager<double, double> {
  @override
  double convertToIn(double outValue) {
    return outValue * 1.25;
  }

  @override
  double convertToOut(double inValue) {
    return inValue * 0.8;
  }
}
