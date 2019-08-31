import 'dart:ui';
import 'package:meta/meta.dart';
import 'package:niks/config/constants.dart';
import 'package:niks/state/state.dart';

import '../errors.dart';

abstract class NiksLayer {
  String uuid;
  bool locked;

  String get layerIdentity;
  Offset get coordinates;
  Size get size;

  void paint(Canvas canvas, Offset offset, NiksState state);

  NiksLayerInstallation install();

  NiksLayerSnapshot createSnapshot();

  bool shouldRepaint();
}

@immutable
abstract class NiksLayerSnapshot<T extends NiksLayer> {
  const NiksLayerSnapshot(this.uuid);

  String get layerIdentity;

  final String uuid;

  T createLayer(T previousLayer);

  Map<String, dynamic> dehydrate();
}

abstract class NiksLayerInstallation<T extends NiksLayer,
    S extends NiksLayerSnapshot<T>> {
  bool checkIdentity(String identity);
  String get identity;
  NiksLayerSnapshot<T> hydrate(Map<String, dynamic> dehydratedLayer);
}

class NiksLayerDefinition {
  List<NiksLayerInstallation> layerInstallations = List();

  void installLayer(NiksLayerInstallation installation) {
    final matches =
        layerInstallations.where((NiksLayerInstallation layerInstallation) {
      return layerInstallation.checkIdentity(installation.identity);
    });
    if (matches.length != 0) {
      throw LayerHydrationError("""
        There is already a layer type installed with this identity: ${installation.identity}.
        Make sure you install this layer type only once
      """);
    }
    layerInstallations.add(installation);
  }

  NiksLayerInstallation verifyLayer(String layerIdentity) {
    return layerInstallations.firstWhere((NiksLayerInstallation installation) {
      return installation.checkIdentity(layerIdentity);
    }, orElse: () {
      throw LayerHydrationError("""
        Could not find a layer type for identity: $layerIdentity.
        Make sure you have installed all layer classes.
      """);
    });
  }

  NiksLayerSnapshot hydrateLayer(Map<String, dynamic> dehydratedLayer) {
    String layerIdentity = dehydratedLayer[layerIdentityKey];
    NiksLayerInstallation installation = verifyLayer(layerIdentity);
    return installation.hydrate(dehydratedLayer);
  }
}
