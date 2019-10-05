import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:letspicture/config/config.dart' as config;
import 'package:letspicture/lib/isolate/isolate_manager.dart';
import 'package:letspicture/storage/project/project_file.dart';
import 'package:letspicture/storage/project/project_model.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  FileUtils._internal();

  static FileUtils _instance;

  String path;

  static FileUtils get instance {
    _instance ??= FileUtils._internal();
    return _instance;
  }

  File originalBitmapFile(Project project) =>
      File("$path/${project.id}.${config.originalBitmapSuffix}");
  File thumbnailFile(Project project) =>
      File("$path/${project.id}.${config.thumbnailSuffix}");
  File editionBitmapFile(Project project) =>
      File("$path/${project.id}.${config.editionFileSuffix}");
  File niksFile(Project project) =>
      File("$path/${project.id}.${config.niksFileSuffix}");

  Future init() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    path = appDocDir.path;
  }

  Future saveProjectOriginalBitmap(
      Project project, ProjectOriginalBitmapFile projectFile) async {
    assert(!project.isTransient);
    final File file = originalBitmapFile(project);
    final File persistedFile = await file.writeAsBytes(projectFile.imageBitmap);
    return persistedFile;
  }

  Future saveProjectThumbnail(
      Project project, ProjectThumbnailFile projectFile) async {
    assert(!project.isTransient);
    final File file = thumbnailFile(project);
    final File persistedFile =
        await file.writeAsBytes(projectFile.thumbnailBitmap);
    return persistedFile;
  }

  Future saveProjectEditionBitmap(
      Project project, ProjectEditionBitmapFile projectFile) async {
    assert(!project.isTransient);
    final File file = editionBitmapFile(project);
    final File persistedFile =
        await file.writeAsBytes(projectFile.editionBitmap);
    return persistedFile;
  }

  Future saveProjectNiks(Project project, ProjectNiksFile projectFile) async {
    assert(!project.isTransient);
    final File file = niksFile(project);
    final File persistedFile = await file.writeAsString(projectFile.fileData);
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
  ImageInfo imageInfo,
  Size imageSize,
) async {
  // get byteData from imageInfo
  final ByteData byteData = await imageInfo.image.toByteData();

  final width = imageSize.width.toInt();
  final height = imageSize.height.toInt();

  final IsolateWorker imageParseWorker = IsolateWorker(imageParseIsolate);
  await imageParseWorker.spawn();
  final List<dynamic> isolateResult = await imageParseWorker.postMessage([
    byteData.buffer.asUint8List(),
    width,
    height,
    config.previewMinWidth,
    config.previewMinHeight,
  ]);
  imageParseWorker.kill();

  final Uint8List bigFile = isolateResult[0];
  final Uint8List smallFile = isolateResult[1];
  final Uint8List previewFile = isolateResult[2];

  final int thumbWidth = isolateResult[3];
  final int thumbHeight = isolateResult[4];

  return [
    ProjectOriginalBitmapFile(bigFile),
    ProjectEditionBitmapFile(smallFile),
    ProjectThumbnailFile(previewFile),
    thumbWidth,
    thumbHeight,
  ];
}
