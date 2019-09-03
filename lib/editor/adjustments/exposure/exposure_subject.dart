import '../adjustments_items.dart';

class ExposureSubjectManager extends ItemSubjectManager<double, double> {
  @override
  double convertToIn(double outValue) {
    return outValue;
  }

  @override
  double convertToOut(double inValue) {
    return inValue;
  }
}
