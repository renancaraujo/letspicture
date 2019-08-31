import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../errors.dart';
import 'adjust_color.dart';
import 'brightness.dart';
import 'contrast.dart';

export 'contrast.dart';
export 'brightness.dart';

const filterIdentityKey = "filterIdentity";

abstract class BitmapLayerFilter {
  String get filterIdentity;

  void apply(Uint8List bitmap, int width, int height, int pixelLength);

  BitmapLayerFilterSnapshot createSnapshot();

  bool shouldRecompute = true;
}

@immutable
abstract class BitmapLayerFilterSnapshot<T extends BitmapLayerFilter> {
  String get filterIdentity;

  T createFilter();

  Map<String, dynamic> dehydrate();
}

BitmapLayerFilterSnapshot hydrateFilter(Map<String, dynamic> dehydratedFilter) {
  String filterIdentity = dehydratedFilter[filterIdentityKey];
  switch (filterIdentity) {
    case contrastIdentity:
      return ContrastFilterSnapshot.hydrate(dehydratedFilter);
    case brightnessIdentity:
      return BrightnessFilterSnapshot.hydrate(dehydratedFilter);
    case adjustColorIdentity:
      return AdjustColorFilterSnapshot.hydrate(dehydratedFilter);
    default:
      throw BitmapFilterHydrationError("""
        Could not find a filter type for identity: $filterIdentity.
      """);
  }
}
