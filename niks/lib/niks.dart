library niks;

import 'dart:typed_data';
import 'dart:ui';
import 'package:uuid/uuid.dart';
import 'layer_types/basic_forms/text.dart';
import 'state/state.dart';
import 'layer/layer.dart';
import 'layer_types/basic_forms/rect.dart';
import 'layer_types/bitmap/bitmap_layer.dart';
import 'package:niks/config/constants.dart' as constants;

export 'layer_types/basic_forms/rect.dart';
export 'state/state.dart';
export 'config/constants.dart';
export 'package:niks/state/state.dart';

class NiksOptions {
  final double width;
  final double height;
  const NiksOptions({this.width, this.height});

  Size get size => Size(width, height);
}

class Niks {
  final NiksOptions options;

  final NiksState state;
  final NiksLayerDefinition _layerDefinition;

  Niks.blank(this.options)
      : this.state = NiksState(),
        this._layerDefinition = NiksLayerDefinition()
          ..installLayer(RectLayerInstallation())
          ..installLayer(BitmapLayerInstallation());

  Niks.hydrate(Map<String, dynamic> dehydratedNiks)
      : this.state = NiksState(),
        this._layerDefinition = NiksLayerDefinition()
          ..installLayer(RectLayerInstallation())
          ..installLayer(BitmapLayerInstallation())
          ..installLayer(TextLayerInstallation()),
        this.options = NiksOptions(
            width: dehydratedNiks[constants.niksProjectWidthKey],
            height: dehydratedNiks[constants.niksProjectHeightKey]) {
    final snapshot = NiksStateSnapshot.hydrate(
        dehydratedNiks[constants.niksStateKey], _layerDefinition);
    state.restoreFromSnapshot(snapshot);
  }

  void addLayerOnTop(NiksLayer layer) {
    _processLayer(layer);
    state.addOnTop(layer);
  }

  void _processLayer(NiksLayer layer) {
    _layerDefinition.verifyLayer(layer.createSnapshot().layerIdentity);
    if (layer.uuid != null) return;
    layer.uuid = Uuid().v4();
  }

  void dispose() {
    state.dispose();
  }

  Map<String, dynamic> dehydrate() {
    final Map<String, dynamic> returnMap = {};
    returnMap[constants.niksVersionKey] = constants.niksVersion;
    returnMap[constants.niksProjectWidthKey] = options.width;
    returnMap[constants.niksProjectHeightKey] = options.height;
    returnMap[constants.niksStateKey] = state.createSnapshot().dehydrate();
    return returnMap;
  }

  Future<Uint8List> generatePicture(ImageByteFormat format) async {
    PictureRecorder recorder = PictureRecorder();

    Canvas canvas = new Canvas(recorder);
    var rect = new Rect.fromLTWH(0.0, 0.0, options.width, options.height);
    canvas.clipRect(rect);
    state.paint(canvas, Offset.zero);

    Image image = await recorder
        .endRecording()
        .toImage(options.width.floor(), options.height.floor());

    final pngBytes = await image.toByteData(format: format);
    return pngBytes.buffer.asUint8List();
  }
}
