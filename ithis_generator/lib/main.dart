import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:niks/layer_types/basic_forms/text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:niks/niks_flutter.dart';
import 'package:niks/niks.dart';

import 'package:niks/layer_types/bitmap/bitmap_layer.dart';
import 'package:bitmap/bitmap.dart';

import 'dart:ui' as ui;

const imageSize = Size(690.0, 362.0);

void main() => runApp(IsThisAnApp());

class IsThisAnApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Is this a niks demo?',
      theme: ThemeData(
        primarySwatch: Colors.grey, // is this a color?
      ),
      home: IsThisAPage(title: 'Is this generator'),
    );
  }
}

class IsThisAPage extends StatefulWidget {
  IsThisAPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _IsThisAPageState createState() => _IsThisAPageState();
}

class _IsThisAPageState extends State<IsThisAPage> {
  Niks skin;
  BitmapLayer butterflyLayer;
  TextLayer faceLayer;
  TextLayer subtitleLayer;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    skin = Niks.blank(
      NiksOptions(width: imageSize.width, height: imageSize.height),
    );
    initLayers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildPreview(context),
            _builldOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double zoom = constraints.maxWidth / imageSize.width;
        return Container(
          width: imageSize.width * zoom,
          height: imageSize.height * zoom,
          transform: Matrix4.identity()..scale(zoom),
          child: NiksRenderWidget(skin),
        );
        ;
      },
    );
  }

  onChangedFaceText(String newFaceText) {
    faceLayer.text = newFaceText;
    print(newFaceText);
    skin.state.markNeedsPaint();
  }

  onChangedSubtitleText(String newSubtitle) {
    subtitleLayer.text = newSubtitle;
  }

  Widget _builldOptions(BuildContext context) {
    return Flexible(
      child: Container(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Field(
                    placeholder: 'Subtitle',
                    onChanged: onChangedSubtitleText,
                  ),
                  Field(
                    placeholder: 'Face text',
                    onChanged: onChangedFaceText,
                  ),
                  RaisedButton(
                    onPressed: changeButterfly,
                    child: Text("Butterfly image"),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  void initLayers() async {
    setState(() {
      loading = true;
    });
    final uint8list = await loadImage();

    BitmapLayer imageLayer = BitmapLayer.fromLTWH(
      Bitmap(
        imageSize.width.toInt(),
        imageSize.height.toInt(),
        uint8list,
      ),
      0,
      0,
      imageSize.width,
      imageSize.height,
    );
    skin.state.addOnTop(imageLayer);
    butterflyLayer = BitmapLayer.fromLTWH(
      Bitmap.blank(130, 130),
      445,
      0,
      130,
      130,
    );
    skin.state.addOnTop(butterflyLayer);

    faceLayer = TextLayer.fromLTWH(
      "",
      107,
      99,
      235,
      46,
      textStyle: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w600,
      ),
    );
    skin.state.addOnTop(faceLayer);

    subtitleLayer = TextLayer.fromLTWH(
      "",
      330,
      278,
      257,
      45,
      textStyle: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    );
    skin.state.addOnTop(subtitleLayer);

    await imageLayer.scheduleImageConversion(skin.state);

    setState(() {
      loading = false;
    });
  }

  void changeButterfly() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    final imageProvider = FileImage(image);
    final imageInfo = await resolveImageInfo(imageProvider);

    ByteData byteData = await imageInfo.image.toByteData();

    final uint8list = byteData.buffer.asUint8List();
    butterflyLayer.bitmap = Bitmap(
      imageInfo.image.width,
      imageInfo.image.height,
      uint8list,
    );

    butterflyLayer.scheduleImageConversion(skin.state);
  }
}

class Field extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String> onChanged;

  const Field({Key key, this.placeholder, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: placeholder,
        ),
      ),
    );
  }
}

Future<Uint8List> loadImage() async {
  const ImageProvider imageProvider = const AssetImage("assets/isthis.png");
  final Completer completer = Completer<ImageInfo>();
  final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
  final listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
    if (!completer.isCompleted) {
      completer.complete(info);
    }
  });
  stream.addListener(listener);
  ImageInfo imageInfo = await completer.future;
  ;
  ByteData byteData = await imageInfo.image.toByteData();
  return byteData.buffer.asUint8List();
}

Future<ImageInfo> resolveImageInfo(imageProvider) {
  final Completer completer = Completer<ImageInfo>();
  final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
  final listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
    if (!completer.isCompleted) {
      completer.complete(info);
    }
  });
  stream.addListener(listener);
  completer.future.then((_) {
    stream.removeListener(listener);
  });
  return completer.future;
}
