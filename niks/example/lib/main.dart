import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui show Image;
import 'package:bitmap/bitmap.dart';
import 'package:flutter/material.dart';
import 'package:niks/history/history.dart';
import 'package:niks/layer/layer.dart';
import 'package:niks/layer_types/bitmap/bitmap_layer.dart';
import 'package:niks/layer_types/bitmap/filters/filter.dart';
import 'package:niks/niks.dart';
import 'package:niks/niks_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NiksBasicExample(),
    );
  }
}

class NiksBasicExample extends StatefulWidget {
  @override
  _NiksBasicExampleState createState() => _NiksBasicExampleState();
}

class _NiksBasicExampleState extends State<NiksBasicExample> {
  Niks skin;
  NiksHistory history;

  ui.Image image;
  BitmapLayer imageLayer;

  ContrastFilter contrastFilter;

  initState() {
    super.initState();

    skin = Niks.blank(NiksOptions(width: 300, height: 300));

    history = NiksHistory(skin, bufferSize: 20);

    loadImage();
  }

  void loadImage() async {
    const ImageProvider imageProvider = const AssetImage("assets/doggo.jpeg");
    final Completer completer = Completer<ImageInfo>();
    final ImageStream stream =
        imageProvider.resolve(const ImageConfiguration());
    final listener =
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      if (!completer.isCompleted) {
        completer.complete(info);
      }
    });
    stream.addListener(listener);
    completer.future.then((info) async {
      ImageInfo imageInfo = info as ImageInfo;
      ByteData data = await imageInfo.image.toByteData();
      setState(() {
        image = imageInfo.image;
      });
      addImage(imageInfo.image, data.buffer.asUint8List());
    });
  }

  addRect() {
    math.Random random = math.Random();
    double width = 5 + 250.0 * random.nextDouble();
    double height = random.nextDouble() * 300;
    double top = random.nextDouble() * 150.0;
    double left = random.nextDouble() * 150.0;

    RectLayer layer = RectLayer.fromLTWH(top, left, width, height);
    layer.color = Colors.amber;

    skin.addLayerOnTop(layer);
    history.addHistory("add react");
  }

  addRect2() {
    math.Random random = math.Random();
    double width = 5 + 295.0 * random.nextDouble();
    double height = random.nextDouble() * 300;
    double top = random.nextDouble() * 150.0;
    double left = random.nextDouble() * 150.0;

    RectLayer layer = RectLayer.fromLTWH(top, left, width, height);
    layer.color = Colors.blue;

    skin.addLayerOnTop(layer);
    history.addHistory("add blue rect");
  }

  addImage(ui.Image image, Uint8List bitmap) {
    double width = 300;
    double height = 300;
    double top = 0;
    double left = 0;

    imageLayer = BitmapLayer.fromLTWH(
        Bitmap(image.width, image.height, bitmap), left, top, width, height);

    contrastFilter = ContrastFilter(1.0);
    imageLayer.addFilter("The contrast", contrastFilter);

    skin.addLayerOnTop(imageLayer);
    history.addHistory("add image");
  }

  void increaseContrast() {
    contrastFilter.contrastRate = contrastFilter.contrastRate + 0.2;
    skin.state.markNeedsPaint();
    history.addHistory("contrast +");
  }

  void decreaseContrast() {
    contrastFilter.contrastRate =
        (contrastFilter.contrastRate - 0.1).clamp(0, 5000);
    history.addHistory("contrast -");
  }

  undo() {
    history.undo();
  }

  redo() {
    history.redo();
    skin.state.markNeedsPaint();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(color: Colors.green),
          height: 35,
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white),
          height: 300,
          width: 300,
          child: Center(
            child: ClipRect(
              child: buildNiks(context),
            ),
          ),
        ),
        ButtonBar(children: <Widget>[
          RaisedButton(
            child: Text("contrast -"),
            onPressed: image == null ? null : decreaseContrast,
          ),
          RaisedButton(
            child: Text("contrast +"),
            onPressed: image == null ? null : increaseContrast,
          ),
          RaisedButton(
            child: Text("add rect"),
            onPressed: addRect,
          ),
        ]),
        ButtonBar(children: <Widget>[
          RaisedButton(
            child: Text("undo"),
            onPressed: undo,
          ),
          RaisedButton(
            child: Text("redo"),
            onPressed: redo,
          ),
        ]),
        Expanded(
            child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.black),
                child: buildHistory(context),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                child: buildLayers(context),
              ),
            ),
          ],
        ))
      ],
    ));
  }

  Widget buildNiks(BuildContext context) {
    return NiksRenderWidget(skin);
  }

  Widget buildHistory(BuildContext context) {
    return StreamBuilder<NiksHistoryState>(
      stream: history.stream,
      builder:
          (BuildContext context, AsyncSnapshot<NiksHistoryState> snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return Container();
        }
        NiksHistoryState data = snapshot.data;
        return ListView.builder(
            itemCount: data.historyBuffer.length,
            itemBuilder: (BuildContext context, int index) {
              NiksHistoryItem item = data.historyBuffer[index];
              return Container(
                decoration: BoxDecoration(
                    color: index == data.activeIndex
                        ? Colors.blueAccent
                        : Colors.transparent),
                child: Text(
                  " ${index} - ${item.name} - ${item.timestamp.toIso8601String()} ",
                  style: TextStyle(color: Colors.white),
                ),
              );
            });
      },
    );
  }

  Widget buildLayers(BuildContext context) {
    return NiksChangesBuilder(
        skin: skin,
        builder: (BuildContext context, Niks skin) {
          return ListView.builder(
              itemCount: skin.state.layers.length,
              itemBuilder: (BuildContext context, int index) {
                NiksLayer item = skin.state.layers.elementAt(index);
                return Container(
                  child: Text(
                    " ${index} - ${item.layerIdentity} - ${item.uuid} ",
                    style: TextStyle(color: Colors.black),
                  ),
                );
              });
        });
  }
}
