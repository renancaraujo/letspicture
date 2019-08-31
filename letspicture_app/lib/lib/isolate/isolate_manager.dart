import 'dart:isolate';
import 'dart:async';
import 'dart:typed_data';

import 'package:letspicture_app/config/config.dart';
import 'package:bitmap/bitmap.dart';

class IsolateWorker {
  final Function _worker;
  ReceivePort _receivePort;
  SendPort _sendPortToIsolate;
  Isolate _isolate;

  IsolateWorker(this._worker);

  Future spawn() async {
    _receivePort = new ReceivePort();
    SendPort sendPortToMe = _receivePort.sendPort;
    _isolate = await Isolate.spawn(this._worker, [sendPortToMe]);
    _sendPortToIsolate = await _receivePort.first;
  }

  void kill() {
    _isolate.kill();
  }

  Future postMessage(message) async {
    ReceivePort responsePort = new ReceivePort();
    _sendPortToIsolate.send([message, responsePort.sendPort]);
    final response = await responsePort.first;
    return response;
  }
}

imageParseIsolate(List initialMessage) async {
  SendPort sendPort = initialMessage[0];

  ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);

  await for (var msg in port) {
    SendPort replyTo = msg[1];

    Uint8List intList = msg[0][0];
    int width = msg[0][1];
    int height = msg[0][2];

    Bitmap bigBitmap = Bitmap(width, height, intList);

    int previewMinWidth = Config.previewMinWidth;
    int previewMinHeight = Config.previewMinHeight;

    Bitmap smallBitmap;

    if (width < previewMinWidth) {
      smallBitmap = bigBitmap.copy();
    } else {
      int resizeWidth = previewMinWidth;
      int resizeHeight;

      double resizeProportion = previewMinWidth / width;
      int supposedHeight = (resizeProportion * height).toInt();

      if (height > previewMinHeight) {
        if (supposedHeight < previewMinHeight) {
          resizeWidth = null;
          resizeHeight = previewMinHeight;
        }
      }

      if (resizeWidth == null) {
        smallBitmap = await bigBitmap.resizeHeight(resizeHeight.toInt());
      } else {
        smallBitmap = await bigBitmap.resizeWidth(resizeWidth.toInt());
      }
    }

    Uint8List bigFile = bigBitmap.contentByteData;
    Uint8List smallFile = smallBitmap.contentByteData;
    Uint8List previewFile = BitmapFile(smallBitmap).bitmapWithHeader;

    int thumbWidth = smallBitmap.width;
    int thumbHeight = smallBitmap.height;

    replyTo.send([bigFile, smallFile, previewFile, thumbWidth, thumbHeight]);
  }
}
