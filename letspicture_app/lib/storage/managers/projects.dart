import 'dart:async';

import 'package:bitmap/bitmap.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letspicture_app/editor/editor.dart';
import 'package:letspicture_app/storage/config/file_manager.dart';
import 'package:letspicture_app/storage/observables/loading.dart';
import 'package:letspicture_app/storage/observables/project_collection.dart';
import 'package:letspicture_app/storage/project/project_file.dart';
import 'dart:io';

import 'package:letspicture_app/storage/project/project_model.dart';
import 'package:niks/layer_types/bitmap/bitmap_layer.dart';

class ProjectsManager {
  static Future importProject() async {
    try {
      // pick image
      File image = await ImagePicker.pickImage(source: ImageSource.gallery);

      // turn loading on
      loadingObservable.updateLoadingInsertProject(true);

      // convert picked to image provider
      ImageProvider imageProvider = FileImage(image);

      // recovery imageInfo from provider
      ImageInfo imageInfo = await _resolveImageInfo(imageProvider);

      Size imageSize =
          Size(imageInfo.image.width / 1, imageInfo.image.height / 1);

      // create transient project model
      Project newProject = Project.createTransient(
        creationDate: image.lastModifiedSync(),
        importDate: DateTime.now(),
        imageSize: imageSize,
      );

      // parse bitmap and create files
      List<dynamic> imageFiles =
          await createProjectImageFilesFromImageInfo(imageInfo, imageSize);

      ProjectOriginalBitmapFile originalBitmapFile =
          imageFiles[0] as ProjectOriginalBitmapFile;
      ProjectEditionBitmapFile editionFile =
          imageFiles[1] as ProjectEditionBitmapFile;
      ProjectThumbnailFile thumbnailFile =
          imageFiles[2] as ProjectThumbnailFile;

      int thumbWidth = imageFiles[3] as int;
      int thumbHeight = imageFiles[4] as int;

      final skin = Editor.createEmptyNiksProject(imageSize);
      ProjectNiksFile niksFile = ProjectNiksFile.fromMap(skin.dehydrate());

      print("now ${originalBitmapFile.fileData.length}");

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

    Future.delayed(Duration(seconds: 1)).then((_) {
      // schedule removal from observable
      projectCollectionObservable.removeProject(project);
    });
    return;
  }

  static Future<ProjectThumbnailFile> saveProject(
      Project project, ProjectNiksFile niksFile, BitmapLayer imageLayer) async {
    FileUtils.instance.saveProjectNiks(project, niksFile);

    int width = project.thumbnailSize.width.toInt();
    int height = project.thumbnailSize.height.toInt();

    // update thumbnail
    final thumbnailBitmap = await imageLayer.resolvedImage.toByteData();
    final a = thumbnailBitmap.buffer.asUint8List();
    BitmapFile file = BitmapFile(Bitmap(width, height, a));
    ProjectThumbnailFile newFile = ProjectThumbnailFile(file.bitmapWithHeader);
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
