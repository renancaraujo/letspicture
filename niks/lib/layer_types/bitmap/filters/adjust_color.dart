import 'dart:typed_data';
import 'package:bitmap/filters.dart';
import 'filter.dart';

const adjustColorIdentity = 'adjustColorFilter';

const blacksKey = 'blacks';
const whitesKey = 'whites';
const saturationKey = 'saturation';
const exposureKey = 'exposure';

class AdjustColorFilter extends BitmapLayerFilter {
  int _blacks;
  int _whites;

  double _saturation;

  double _exposure;

  int get blacks => _blacks;

  set blacks(int value) {
    _blacks = value;
    shouldRecompute = true;
  }

  int get whites => _whites;

  set whites(int value) {
    _whites = value;
    shouldRecompute = true;
  }

  double get saturation => _saturation;

  set saturation(double value) {
    _saturation = value;
    shouldRecompute = true;
  }

  double get exposure => _exposure;

  set exposure(double value) {
    _exposure = value;
    shouldRecompute = true;
  }

  AdjustColorFilter(
      {int blacks,
      int whites,
      double saturation,
      double gamma,
      double exposure})
      : _blacks = blacks,
        _whites = whites,
        _saturation = saturation,
        _exposure = exposure;

  AdjustColorFilter.fromSnapshot(AdjustColorFilterSnapshot snapshot)
      : _blacks = snapshot.blacks,
        _whites = snapshot.whites,
        _saturation = snapshot.saturation,
        _exposure = snapshot.exposure;

  @override
  void apply(Uint8List bitmap, int width, int height, int pixelLength) {
    adjustColorFunction(
      bitmap,
      blacks: _blacks,
      whites: _whites,
      saturation: _saturation,
      exposure: _exposure,
    );
  }

  @override
  BitmapLayerFilterSnapshot<BitmapLayerFilter> createSnapshot() {
    return AdjustColorFilterSnapshot(this);
  }

  @override
  String get filterIdentity => adjustColorIdentity;
}

class AdjustColorFilterSnapshot
    extends BitmapLayerFilterSnapshot<AdjustColorFilter> {
  final int blacks;
  final int whites;
  final double saturation;
  final double exposure;

  AdjustColorFilterSnapshot(AdjustColorFilter filter)
      : blacks = filter._blacks,
        whites = filter._whites,
        saturation = filter._saturation,
        exposure = filter._exposure;

  AdjustColorFilterSnapshot.hydrate(Map<String, dynamic> dehydratedFilter)
      : blacks = dehydratedFilter[blacksKey],
        whites = dehydratedFilter[whitesKey],
        saturation = dehydratedFilter[saturationKey],
        exposure = dehydratedFilter[exposureKey];

  @override
  AdjustColorFilter createFilter() {
    return AdjustColorFilter.fromSnapshot(this);
  }

  @override
  Map<String, dynamic> dehydrate() {
    final Map<String, dynamic> returnMap = {};

    returnMap[filterIdentityKey] = filterIdentity;
    returnMap[blacksKey] = blacks;
    returnMap[whitesKey] = whites;
    returnMap[saturationKey] = saturation;
    returnMap[exposureKey] = exposure;

    return returnMap;
  }

  @override
  String get filterIdentity => adjustColorIdentity;
}
