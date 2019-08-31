import 'package:photo_view/photo_view.dart';

class MyPhotoViewController extends PhotoViewController {
  bool locked;

  @override
  set value(PhotoViewControllerValue newValue) {
    if (locked) {
      return;
    }
    super.value = newValue;
  }

  @override
  void setScaleInvisibly(double scale) {
    if (locked) {
      return;
    }
    super.setScaleInvisibly(scale);
  }
}

PhotoViewScaleState lockedScaleStateCycle(PhotoViewScaleState actual) {
  return actual;
}
