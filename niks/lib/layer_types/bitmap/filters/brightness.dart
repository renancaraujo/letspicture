import 'dart:typed_data';

import 'package:bitmap/filters.dart';

import 'filter.dart';

const brightnessIdentity = 'brightnessFilter';
const brightnessRateKey = 'brightnessRate';

class BrightnessFilter extends BitmapLayerFilter {
  double _brightnessRate;
  double get brightnessRate => _brightnessRate;
  set brightnessRate(double brightnessRate) {
    _brightnessRate = brightnessRate;
    shouldRecompute = true;
  }

  BrightnessFilter(this._brightnessRate);

  BrightnessFilter.fromSnapshot(BrightnessFilterSnapshot snapshot)
      : this._brightnessRate = snapshot._brightnessRate;

  @override
  BitmapLayerFilterSnapshot<BitmapLayerFilter> createSnapshot() {
    return BrightnessFilterSnapshot(this);
  }

  @override
  String get filterIdentity => brightnessIdentity;

  @override
  void apply(Uint8List bitmap, int width, int height, int pixelLength) {
    setBrightnessFunction(bitmap, _brightnessRate);
  }
}

class BrightnessFilterSnapshot
    extends BitmapLayerFilterSnapshot<BrightnessFilter> {
  final double _brightnessRate;

  BrightnessFilterSnapshot(BrightnessFilter brightnessFilter)
      : this._brightnessRate = brightnessFilter._brightnessRate;

  BrightnessFilterSnapshot.hydrate(Map<String, dynamic> dehydratedFilter)
      : _brightnessRate = dehydratedFilter[brightnessRateKey];

  @override
  BrightnessFilter createFilter() {
    return BrightnessFilter.fromSnapshot(this);
  }

  @override
  Map<String, dynamic> dehydrate() {
    final Map<String, dynamic> returnMap = {};

    returnMap[filterIdentityKey] = filterIdentity;
    returnMap[brightnessRateKey] = _brightnessRate;

    return returnMap;
  }

  @override
  String get filterIdentity => brightnessIdentity;
}
