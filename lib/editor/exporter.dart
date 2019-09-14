import 'dart:typed_data';
import 'dart:ui';

import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:letspicture/storage/config/file_manager.dart';
import 'package:letspicture/storage/project/project_model.dart';
import 'editor.dart';

enum ExportConfig { original, fast, mini }

class Exporter {
  static Future<void> saveImageToGallery(
      ExportConfig config, Project project) async {
    Uint8List transformedIntList;

    switch (config) {
      case ExportConfig.fast:
        transformedIntList = await _saveImageToGalleryFast(config, project);
        break;
      case ExportConfig.original:
      default:
        transformedIntList = await _saveImageToGalleryOriginal(config, project);
    }

    await ImagePickerSaver.saveFile(fileData: transformedIntList);
  }

  static Future<Uint8List> _saveImageToGalleryOriginal(
      ExportConfig config, Project project) async {
    final originalProject =
        await FileUtils.instance.openProjectOriginalBitmap(project);

    return await Editor.instance
        .exportImage(originalProject.fileData, project.imageSize);
  }

  static Future<Uint8List> _saveImageToGalleryFast(
      ExportConfig config, Project project) async {
    return await Editor.instance.skin.generatePicture(ImageByteFormat.png);
  }
}
