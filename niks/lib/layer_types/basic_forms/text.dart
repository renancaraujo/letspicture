import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:niks/config/constants.dart';
import 'package:niks/layer/layer.dart';
import 'package:niks/state/state.dart';

const String textIdentity = "Text";
const String widthKey = "width";
const String heightKey = "height";
const String xKey = "x";
const String yKey = "y";
const String colorValueKey = "colorValue";
const String textKey = "text";
const String fontSizeKey = "fontSize";

class TextLayer implements NiksLayer {
  bool _pendingRepaint = true;

  @override
  bool locked;

  @override
  String uuid;

  @override
  Offset get coordinates => _coordinates;

  set coordinates(Offset newCoordinates) {
    _coordinates = newCoordinates;
    _pendingRepaint = true;
  }

  Offset _coordinates;

  @override
  Size get size => _size;

  set size(Size newSize) {
    _size = newSize;
    _pendingRepaint = true;
  }

  Size _size;

  String get text => _text;

  set text(String text) {
    _text = text;
    _pendingRepaint = true;
  }

  String _text;

  TextStyle get textStyle => _textStyle;

  set textStyle(TextStyle textStyle) {
    _textStyle = textStyle;
    _pendingRepaint = true;
  }

  TextStyle _textStyle;

  TextLayer.fromLTWH(
      this._text, double left, double top, double width, double height,
      {TextStyle textStyle})
      : _size = Size(width, height),
        _coordinates = Offset(left, top),
        _textStyle = textStyle,
        super();

  TextLayer.fromSnapshot(TextLayerSnapshot snapshot)
      : uuid = snapshot.uuid,
        _size = Size(snapshot.width, snapshot.height),
        _coordinates = Offset(snapshot.x, snapshot.y),
        _text = snapshot.text,
        _textStyle = TextStyle(
          color: Color(snapshot.colorValue),
          fontSize: snapshot.fontSize,
        ),
        super();

  @override
  NiksLayerSnapshot<NiksLayer> createSnapshot() {
    // TODO: implement createSnapshot
    return null;
  }

  @override
  TextLayerInstallation install() {
    return TextLayerInstallation();
  }

  @override
  String get layerIdentity => textIdentity;

  @override
  void paint(Canvas canvas, Offset offset, NiksState state) {
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final offset = coordinates;
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint() => _pendingRepaint;
}

class TextLayerSnapshot implements NiksLayerSnapshot<TextLayer> {
  @override
  final String uuid;

  final double width;
  final double height;
  final double x;
  final double y;
  final int colorValue;
  final String text;
  final double fontSize;

  @override
  String get layerIdentity => textIdentity;

  TextLayerSnapshot(TextLayer layer)
      : uuid = layer.uuid,
        width = layer.size.width,
        height = layer.size.height,
        x = layer.coordinates.dx,
        y = layer.coordinates.dy,
        colorValue = layer.textStyle.color.value,
        fontSize = layer.textStyle.fontSize,
        text = layer.text;

  TextLayerSnapshot.hydrate(Map<String, dynamic> dehydratedLayer)
      : uuid = dehydratedLayer[UUIDKey],
        width = dehydratedLayer[widthKey],
        height = dehydratedLayer[heightKey],
        x = dehydratedLayer[xKey],
        y = dehydratedLayer[yKey],
        colorValue = dehydratedLayer[colorValueKey],
        text = dehydratedLayer[textKey],
        fontSize = dehydratedLayer[fontSizeKey];

  @override
  TextLayer createLayer(TextLayer previousLayer) {
    return TextLayer.fromSnapshot(this);
  }

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
    returnMap[textKey] = text;
    returnMap[fontSizeKey] = fontSize;

    return returnMap;
  }
}

class TextLayerInstallation
    extends NiksLayerInstallation<TextLayer, TextLayerSnapshot> {
  @override
  TextLayerSnapshot hydrate(Map<String, dynamic> dehydratedLayer) {
    return TextLayerSnapshot.hydrate(dehydratedLayer);
  }

  @override
  bool checkIdentity(String identity) {
    return identity == this.identity;
  }

  @override
  String get identity => textIdentity;
}
