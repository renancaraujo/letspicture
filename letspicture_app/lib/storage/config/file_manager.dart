import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:letspicture_app/config/config.dart';
import 'package:letspicture_app/lib/isolate/isolate_manager.dart';
import 'package:letspicture_app/storage/project/project_file.dart';
import 'package:letspicture_app/storage/project/project_model.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  FileUtils._internal();

  static FileUtils _instance;

  String path;

  static FileUtils get instance {
    if (_instance == null) {
      _instance = FileUtils._internal();
    }
    return _instance;
  }

  File originalBitmapFile(Project project) =>
      File("$path/${project.id}.${Config.originaiBitmapSuffix}");
  File thumbnailFile(Project project) =>
      File("$path/${project.id}.${Config.thumbnailSuffix}");
  File editionBitmapFile(Project project) =>
      File("$path/${project.id}.${Config.editionFileSuffix}");
  File niksFile(Project project) =>
      File("$path/${project.id}.${Config.niksFileSuffix}");

  Future init() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    path = appDocDir.path;
  }

  Future saveProjectOriginalBitmap(
      Project project, ProjectOriginalBitmapFile projectFile) async {
    assert(!project.isTransient);
    File file = originalBitmapFile(project);
    File persistedFile = await file.writeAsBytes(projectFile.imageBitmap);
    return persistedFile;
  }

  Future saveProjectThumbnail(
      Project project, ProjectThumbnailFile projectFile) async {
    assert(!project.isTransient);
    File file = thumbnailFile(project);
    File persistedFile = await file.writeAsBytes(projectFile.thumbnailBitmap);
    return persistedFile;
  }

  Future saveProjectEditionBitmap(
      Project project, ProjectEditionBitmapFile projectFile) async {
    assert(!project.isTransient);
    File file = editionBitmapFile(project);
    File persistedFile = await file.writeAsBytes(projectFile.editionBitmap);
    return persistedFile;
  }

  Future saveProjectNiks(Project project, ProjectNiksFile projectFile) async {
    assert(!project.isTransient);
    File file = niksFile(project);
    File persistedFile = await file.writeAsString(projectFile.fileData);
    return persistedFile;
  }

  Future deleteProjectFiles(Project project) async {
    assert(!project.isTransient);

    final futures = <Future>[
      originalBitmapFile(project).delete(),
      thumbnailFile(project).delete(),
      editionBitmapFile(project).delete(),
      niksFile(project).delete()
    ];
    await Future.wait(futures);
  }

  Future<ProjectOriginalBitmapFile> openProjectOriginalBitmap(
      Project project) async {
    final byteData = await originalBitmapFile(project).readAsBytes();
    project.originalBitmapFile = ProjectOriginalBitmapFile(byteData);
    return project.originalBitmapFile;
  }

  Future<ProjectThumbnailFile> openProjectThumbnailFile(Project project) async {
    final byteData = await thumbnailFile(project).readAsBytes();
    project.thumbnailFile = ProjectThumbnailFile(byteData);
    return project.thumbnailFile;
  }

  Future<ProjectEditionBitmapFile> openProjectEditionBitmapFile(
      Project project) async {
    final byteData = await editionBitmapFile(project).readAsBytes();
    project.editionBitmapFile = ProjectEditionBitmapFile(byteData);
    return project.editionBitmapFile;
  }

  Future<ProjectNiksFile> openProjectNiksFile(Project project) async {
    final json = await niksFile(project).readAsString();
    project.niksFile = ProjectNiksFile(json);
    return project.niksFile;
  }
}

Future<List<dynamic>> createProjectImageFilesFromImageInfo(
    ImageInfo imageInfo, Size imageSize) async {
  // get byteData from imageInfo
  ByteData byteData = await imageInfo.image.toByteData();

  int width = imageSize.width.toInt();
  int height = imageSize.height.toInt();

  IsolateWorker imageParseWorker = new IsolateWorker(imageParseIsolate);
  await imageParseWorker.spawn();
  List<dynamic> isolateResult = await imageParseWorker.postMessage([
    byteData.buffer.asUint8List(),
    width,
    height,
    Config.previewMinWidth,
    Config.previewMinHeight,
  ]);
  imageParseWorker.kill();

  Uint8List bigFile = isolateResult[0];
  Uint8List smallFile = isolateResult[1];
  Uint8List previewFile = isolateResult[2];

  int thumbWidth = isolateResult[3];
  int thumbHeight = isolateResult[4];

  return [
    ProjectOriginalBitmapFile(bigFile),
    ProjectEditionBitmapFile(smallFile),
    ProjectThumbnailFile(previewFile),
    thumbWidth,
    thumbHeight,
  ];
}
