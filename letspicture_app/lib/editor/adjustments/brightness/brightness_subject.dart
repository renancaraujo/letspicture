import '../adjustments_items.dart';

class BrightnessSubjectManager extends ItemSubjectManager<double, double> {
  @override
  double convertToIn(double brightnessRate) {
    return brightnessRate * 1.25;
  }

  @override
  double convertToOut(double brightnessValue) {
    return brightnessValue * 0.8;
  }
}
