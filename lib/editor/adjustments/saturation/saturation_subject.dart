import '../adjustments_items.dart';

class SaturationSubjectManager extends ItemSubjectManager<double, double> {
  @override
  double convertToIn(double outValue) {
    if (outValue == null) {
      return 0.0;
    }
    if (outValue > 1.0) {
      return (outValue - 1) / 4;
    } else if (outValue < 1.0) {
      return outValue - 1;
    }
    return 0.0;
  }

  @override
  double convertToOut(double inValue) {
    if (inValue > 0.0) {
      return inValue * 4 + 1;
    } else if (inValue < 0.0) {
      return 1 + inValue;
    }
    return 1.0;
  }
}
