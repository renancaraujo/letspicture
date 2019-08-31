import 'dart:convert';
import 'dart:typed_data';

abstract class ProjectFile<ContentType> {
  ContentType get fileData;
}

class ProjectOriginalBitmapFile implements ProjectFile<Uint8List> {
  final Uint8List imageBitmap;

  ProjectOriginalBitmapFile(this.imageBitmap);

  Uint8List get fileData => imageBitmap;
}

class ProjectThumbnailFile implements ProjectFile<Uint8List> {
  final Uint8List thumbnailBitmap;

  ProjectThumbnailFile(this.thumbnailBitmap);

  Uint8List get fileData => thumbnailBitmap;
}

class ProjectEditionBitmapFile implements ProjectFile<Uint8List> {
  final Uint8List editionBitmap;

  ProjectEditionBitmapFile(this.editionBitmap);

  Uint8List get fileData => editionBitmap;
}

class ProjectNiksFile implements ProjectFile<String> {
  final Map<String, dynamic> json;

  ProjectNiksFile(String contents) : this.json = jsonDecode(contents);

  ProjectNiksFile.fromMap(this.json);

  @override
  String get fileData {
    return new JsonEncoder().convert(json);
  }
}
