import '../adjustments_items.dart';

class BlacksSubjectManager extends ItemSubjectManager<double, int> {
  @override
  double convertToIn(int outValue) {
    if (outValue == null) {
      return 0.0;
    }
    return outValue.toDouble();
  }

  @override
  int convertToOut(double inValue) {
    return inValue.floor();
  }
}
