import '../adjustments_items.dart';

class ContrastSubjectManager extends ItemSubjectManager<double, double> {
  @override
  double convertToIn(double contrastRate) {
    assert(contrastRate >= 0.0);
    if (contrastRate > 1.0) {
      return (contrastRate - 1) * 3;
    } else if (contrastRate < 1.0) {
      return (contrastRate - 1) / 0.2;
    }
    return 0.0;
  }

  @override
  double convertToOut(double contrastValue) {
    assert(contrastValue <= 1.0 && contrastValue >= -1.0);

    if (contrastValue > 0.0) {
      return contrastValue / 3 + 1;
    } else if (contrastValue < 0.0) {
      return 1 + (contrastValue * 0.2);
    }
    return 1.0;
  }
}
