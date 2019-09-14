import '../adjustments_items.dart';

class ContrastSubjectManager extends ItemSubjectManager<double, double> {
  @override
  double convertToIn(double outValue) {
    assert(outValue >= 0.0);
    if (outValue > 1.0) {
      return (outValue - 1) / 1.1;
    } else if (outValue < 1.0) {
      return (outValue - 1) / 0.2;
    }
    return 0.0;
  }

  @override
  double convertToOut(double inValue) {
    assert(inValue <= 1.0 && inValue >= -1.0);
    if (inValue > 0.0) {
      return inValue * 1.1 + 1;
    } else if (inValue < 0.0) {
      return 1 + (inValue * 0.2);
    }
    return 1.0;
  }
}
