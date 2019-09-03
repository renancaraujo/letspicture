import 'dart:convert';
import 'dart:typed_data';

abstract class ProjectFile<ContentType> {
  ContentType get fileData;
}

class ProjectOriginalBitmapFile implements ProjectFile<Uint8List> {
  ProjectOriginalBitmapFile(this.imageBitmap);

  final Uint8List imageBitmap;

  @override
  Uint8List get fileData => imageBitmap;
}

class ProjectThumbnailFile implements ProjectFile<Uint8List> {
  ProjectThumbnailFile(this.thumbnailBitmap);

  final Uint8List thumbnailBitmap;

  @override
  Uint8List get fileData => thumbnailBitmap;
}

class ProjectEditionBitmapFile implements ProjectFile<Uint8List> {
  ProjectEditionBitmapFile(this.editionBitmap);

  final Uint8List editionBitmap;

  @override
  Uint8List get fileData => editionBitmap;
}

class ProjectNiksFile implements ProjectFile<String> {
  ProjectNiksFile(String contents) : json = jsonDecode(contents);

  ProjectNiksFile.fromMap(this.json);

  final Map<String, dynamic> json;

  @override
  String get fileData {
    return const JsonEncoder().convert(json);
  }
}
