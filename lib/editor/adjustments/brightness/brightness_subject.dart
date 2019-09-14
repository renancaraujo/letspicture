import '../adjustments_items.dart';

const negativeFactor = 0.8;
const positiveFactor = 0.4;

class BrightnessSubjectManager extends ItemSubjectManager<double, double> {
  @override
  double convertToIn(double outValue) {
    if (outValue > 0.0) {
      return outValue / positiveFactor;
    } else if (outValue < 0.0) {
      return outValue / negativeFactor;
    }
    return 0.0;
  }

  @override
  double convertToOut(double inValue) {
    if (inValue > 0.0) {
      return inValue * positiveFactor;
    } else if (inValue < 0.0) {
      return inValue * negativeFactor;
    }
    return 0.0;
  }
}
