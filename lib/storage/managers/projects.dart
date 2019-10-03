import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bitmap/bitmap.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letspicture/editor/editor.dart';
import 'package:letspicture/storage/config/file_manager.dart';
import 'package:letspicture/storage/observables/loading.dart';
import 'package:letspicture/storage/observables/project_collection.dart';
import 'package:letspicture/storage/project/project_file.dart';
import 'package:letspicture/storage/project/project_model.dart';
import 'package:niks_bitmap/niks_bitmap.dart';

class ProjectsManager {
  static Future importProject() async {
    try {
      // pick image
      final File image =
          await ImagePicker.pickImage(source: ImageSource.gallery);

      // turn loading on
      loadingObservable.updateLoadingInsertProject(true);

      // convert picked to image provider
      final ImageProvider imageProvider = FileImage(image);

      // recovery imageInfo from provider
      final ImageInfo imageInfo = await _resolveImageInfo(imageProvider);

      final Size imageSize = Size(
        imageInfo.image.width / 1,
        imageInfo.image.height / 1,
      );

      // create transient project model
      final Project newProject = Project.createTransient(
        creationDate: image.lastModifiedSync(),
        importDate: DateTime.now(),
        imageSize: imageSize,
      );

      // parse bitmap and create files
      final List<dynamic> imageFiles =
          await createProjectImageFilesFromImageInfo(imageInfo, imageSize);

      final ProjectOriginalBitmapFile originalBitmapFile =
          imageFiles[0] as ProjectOriginalBitmapFile;
      final ProjectEditionBitmapFile editionFile =
          imageFiles[1] as ProjectEditionBitmapFile;
      final ProjectThumbnailFile thumbnailFile =
          imageFiles[2] as ProjectThumbnailFile;

      final thumbWidth = imageFiles[3] as int;
      final thumbHeight = imageFiles[4] as int;

      final skin = Editor.createEmptyNiksProject(imageSize);
      final ProjectNiksFile niksFile =
          ProjectNiksFile.fromMap(skin.dehydrate());

      // turn loading off
      loadingObservable.updateLoadingInsertProject(false);

      // add preview to memory
      newProject.thumbnailFile = thumbnailFile;

      // add niks to memory
      newProject.niksFile = niksFile;

      // set thumbnail size
      newProject.thumbnailSize =
          Size(thumbWidth.toDouble(), thumbHeight.toDouble());

      // add to sqlite
      await newProject.persist();

      final futures = <Future>[
        FileUtils.instance
            .saveProjectOriginalBitmap(newProject, originalBitmapFile),
        FileUtils.instance.saveProjectEditionBitmap(newProject, editionFile),
        FileUtils.instance.saveProjectThumbnail(newProject, thumbnailFile),
        FileUtils.instance.saveProjectNiks(newProject, niksFile),
      ];

      // save project files
      await Future.wait(futures);

      // add to in memory observable
      projectCollectionObservable.insertProject(newProject);
    } catch (e) {
      loadingObservable.updateLoadingInsertProject(false);
    }
  }

  static Future deleteProject(Project project) async {
    // delete on database
    await project.delete();

    // delete files
    await FileUtils.instance.deleteProjectFiles(project);

    Future.delayed(const Duration(seconds: 1)).then((_) {
      // schedule removal from observable
      projectCollectionObservable.removeProject(project);
    });
    return;
  }

  static Future<ProjectThumbnailFile> saveProject(
      Project project, ProjectNiksFile niksFile, BitmapLayer imageLayer) async {
    FileUtils.instance.saveProjectNiks(project, niksFile);

    final int width = project.thumbnailSize.width.toInt();
    final int height = project.thumbnailSize.height.toInt();

    // update thumbnail
    final thumbnailBitmap = await imageLayer.resolvedImage.toByteData();
    final a = thumbnailBitmap.buffer.asUint8List();
    final Uint8List fileContent =
        Bitmap.fromHeadless(width, height, a).buildHeaded();
    final ProjectThumbnailFile newFile = ProjectThumbnailFile(fileContent);
    FileUtils.instance.saveProjectThumbnail(project, newFile);

    return newFile;
  }
}

Future<ImageInfo> _resolveImageInfo(imageProvider) {
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
