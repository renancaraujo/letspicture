import '../adjustments_items.dart';

class ExposureSubjectManager extends ItemSubjectManager<double, double> {
  @override
  double convertToIn(double out) {
    return out;
  }

  @override
  double convertToOut(double inValue) {
    return inValue;
  }
}
