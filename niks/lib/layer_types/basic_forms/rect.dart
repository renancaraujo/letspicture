import 'dart:ui';

import 'package:niks/config/constants.dart';
import 'package:niks/layer/layer.dart';
import 'package:niks/state/state.dart';

const String rectIdentity = "Rect";
const String widthKey = "width";
const String heightKey = "height";
const String xKey = "x";
const String yKey = "y";
const String colorValueKey = "colorValue";

class RectLayer implements NiksLayer {
  @override
  bool locked;

  @override
  String uuid;

  @override
  Size get size => _size;

  set size(Size newSize) {
    _size = newSize;
    _pendingRepaint = true;
  }

  @override
  Offset get coordinates => _coordinates;

  set coordinates(Offset newCoordinates) {
    _coordinates = newCoordinates;
    _pendingRepaint = true;
  }

  @override
  Color get color => _color;

  set color(Color newColor) {
    _color = newColor;
    _pendingRepaint = true;
  }

  Color _color;
  Size _size;
  Offset _coordinates;
  bool _pendingRepaint = true;

  RectLayer.fromLTWH(double left, double top, double width, double height,
      [this._color = const Color(0xFFFFFFFF)])
      : _size = Size(width, height),
        _coordinates = Offset(left, top),
        super();

  RectLayer.fromSnapshot(RectLayerSnapshot snapshot)
      : uuid = snapshot.uuid,
        _size = Size(snapshot.width, snapshot.height),
        _coordinates = Offset(snapshot.x, snapshot.y),
        _color = Color(snapshot.colorValue),
        super();

  @override
  NiksLayerSnapshot<NiksLayer> createSnapshot() {
    return RectLayerSnapshot(this);
  }

  @override
  NiksLayerInstallation<NiksLayer, NiksLayerSnapshot<NiksLayer>> install() {
    return RectLayerInstallation();
  }

  @override
  void paint(Canvas canvas, Offset offset, NiksState state) {
    canvas.drawRect(
      new Rect.fromLTWH(
          coordinates.dx, coordinates.dy, size.width, size.height),
      new Paint()..color = color,
    );

    _pendingRepaint = false;
  }

  @override
  String get layerIdentity => rectIdentity;

  @override
  bool shouldRepaint() => _pendingRepaint;
}

class RectLayerSnapshot implements NiksLayerSnapshot<RectLayer> {
  @override
  final String uuid;

  @override
  String get layerIdentity => rectIdentity;

  final double width;
  final double height;
  final double x;
  final double y;
  final int colorValue;

  RectLayerSnapshot(RectLayer layer)
      : uuid = layer.uuid,
        width = layer.size.width,
        height = layer.size.height,
        x = layer.coordinates.dx,
        y = layer.coordinates.dy,
        colorValue = layer.color.value;

  RectLayerSnapshot.hydrate(Map<String, dynamic> dehydratedLayer)
      : uuid = dehydratedLayer[UUIDKey],
        width = dehydratedLayer[widthKey],
        height = dehydratedLayer[heightKey],
        x = dehydratedLayer[xKey],
        y = dehydratedLayer[yKey],
        colorValue = dehydratedLayer[colorValueKey];

  @override
  Map<String, dynamic> dehydrate() {
    final Map<String, dynamic> returnMap = {};

    returnMap[layerIdentityKey] = layerIdentity;
    returnMap[UUIDKey] = uuid;
    returnMap[widthKey] = width;
    returnMap[heightKey] = height;
    returnMap[xKey] = x;
    returnMap[yKey] = y;
    returnMap[colorValueKey] = colorValue;

    return returnMap;
  }

  @override
  RectLayer createLayer(RectLayer previousLayer) {
    return RectLayer.fromSnapshot(this);
  }
}

class RectLayerInstallation
    extends NiksLayerInstallation<RectLayer, RectLayerSnapshot> {
  @override
  RectLayerSnapshot hydrate(final Map<String, dynamic> dehydratedLayer) {
    return RectLayerSnapshot.hydrate(dehydratedLayer);
  }

  @override
  bool checkIdentity(String identity) {
    return identity == this.identity;
  }

  @override
  String get identity => rectIdentity;
}
