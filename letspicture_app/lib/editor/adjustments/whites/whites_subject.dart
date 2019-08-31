import '../adjustments_items.dart';

class WhitesSubjectManager extends ItemSubjectManager<double, int> {
  @override
  double convertToIn(int out) {
    if (out == null) return 255.0;
    return out.toDouble();
  }

  @override
  int convertToOut(double inValue) {
    return inValue.floor();
  }
}
