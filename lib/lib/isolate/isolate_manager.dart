import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:bitmap/bitmap.dart';
import 'package:bitmap/transformations.dart' as bmp_transform;
import 'package:letspicture/config/config.dart' as config;

class IsolateWorker {
  IsolateWorker(this._worker);

  final Function _worker;
  ReceivePort _receivePort;
  SendPort _sendPortToIsolate;
  Isolate _isolate;

  Future spawn() async {
    _receivePort = ReceivePort();
    final SendPort sendPortToMe = _receivePort.sendPort;
    _isolate = await Isolate.spawn(_worker, [sendPortToMe]);
    _sendPortToIsolate = await _receivePort.first;
  }

  void kill() {
    _isolate.kill();
  }

  Future postMessage(message) async {
    final ReceivePort responsePort = ReceivePort();
    _sendPortToIsolate.send([message, responsePort.sendPort]);
    final response = await responsePort.first;
    return response;
  }
}

void imageParseIsolate(List initialMessage) async {
  final SendPort sendPort = initialMessage[0];

  final ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);

  await for (var msg in port) {
    final SendPort replyTo = msg[1];

    final Uint8List intList = msg[0][0];
    final int width = msg[0][1];
    final int height = msg[0][2];

    final Bitmap bigBitmap = Bitmap.fromHeadless(width, height, intList);

    const previewMinWidth = config.previewMinWidth;
    const previewMinHeight = config.previewMinHeight;

    Bitmap smallBitmap;

    if (width < previewMinWidth) {
      smallBitmap = bigBitmap.cloneHeadless();
    } else {
      int resizeWidth = previewMinWidth;
      int resizeHeight;

      final double resizeProportion = previewMinWidth / width;
      final int supposedHeight = (resizeProportion * height).toInt();

      if (height > previewMinHeight) {
        if (supposedHeight < previewMinHeight) {
          resizeWidth = null;
          resizeHeight = previewMinHeight;
        }
      }

      if (resizeWidth == null) {
        smallBitmap =
            await bmp_transform.resizeHeight(bigBitmap, resizeHeight.toInt());
      } else {
        smallBitmap =
            await bmp_transform.resizeWidth(bigBitmap, resizeWidth.toInt());
      }
    }

    final Uint8List bigFile = bigBitmap.content;
    final Uint8List smallFile = smallBitmap.content;
    final Uint8List previewFile = smallBitmap.buildHeaded();

    final thumbWidth = smallBitmap.width;
    final thumbHeight = smallBitmap.height;

    replyTo.send([bigFile, smallFile, previewFile, thumbWidth, thumbHeight]);
  }
}
