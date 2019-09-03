import '../adjustments_items.dart';

class WhitesSubjectManager extends ItemSubjectManager<double, int> {
  @override
  double convertToIn(int outValue) {
    if (outValue == null) {
      return 255.0;
    }
    return outValue.toDouble();
  }

  @override
  int convertToOut(double inValue) {
    return inValue.floor();
  }
}
