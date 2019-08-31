import '../adjustments_items.dart';

class SaturationSubjectManager extends ItemSubjectManager<double, double> {
  @override
  double convertToIn(double saturationRate) {
    if (saturationRate == null) return 0.0;
    if (saturationRate > 1.0) {
      return (saturationRate - 1) / 4;
    } else if (saturationRate < 1.0) {
      return saturationRate - 1;
    }
    return 0.0;
  }

  @override
  double convertToOut(double saturationValue) {
    if (saturationValue > 0.0) {
      return saturationValue * 4 + 1;
    } else if (saturationValue < 0.0) {
      return 1 + (saturationValue);
    }
    return 1.0;
  }
}
