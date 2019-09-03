/*

Editor editor = Editor();

await editor.mountNiks(project);

editor unmoint niks

editor.niks;

editor.setContrast(0.1);



await editor.saveFile(SaveFileConfig.original);

NiksRenderWidget()


strem changes to project file json ();

 */

import 'dart:typed_data';
import 'dart:ui';
import 'package:bitmap/bitmap.dart';
import 'package:letspicture/storage/config/file_manager.dart';
import 'package:letspicture/storage/managers/projects.dart';
import 'package:letspicture/storage/observables/project.dart';
import 'package:letspicture/storage/project/project_file.dart';
import 'package:letspicture/storage/project/project_model.dart';
import 'package:niks/niks.dart';
import 'package:niks_bitmap/niks_bitmap.dart';

const imageLayerID = "ImageLayer";

const contrastFilterID = "ContrastFilter";
const brightnessFilterID = "BrightnessFilter";
const adjustColorFilterID = "AdjustColorFilterFilter";

class Editor {
  Editor._internal();

  static Editor _instance;

  static Editor get instance {
    _instance ??= Editor._internal();
    return _instance;
  }

  static Niks createEmptyNiksProject(Size imageSize) {
    final width = imageSize.width;
    final height = imageSize.height;

    final Niks skin = Niks.blank(NiksOptions(width: width, height: height));
    skin.installLayer(BitmapLayerInstallation());
    final BitmapLayer imageLayer = BitmapLayer.fromLTWH(
      Bitmap.blank(
        width.toInt(),
        height.toInt(),
      ),
      0,
      0,
      width,
      height,
    );
    imageLayer.uuid = imageLayerID;
    skin.state.addOnTop(imageLayer);

    final ContrastFilter contrastFilter = ContrastFilter(1.0);
    imageLayer.addFilter(contrastFilterID, contrastFilter);

    final BrightnessFilter brightnessFilter = BrightnessFilter(0.0);
    imageLayer.addFilter(brightnessFilterID, brightnessFilter);

    final AdjustColorFilter adjustColorFilter = AdjustColorFilter();
    imageLayer.addFilter(adjustColorFilterID, adjustColorFilter);

    return skin;
  }

  Niks skin;
  ProjectObservable projectObservable;
  BitmapLayer imageLayer;
  ContrastFilter contrastFilter;
  BrightnessFilter brightnessFilter;
  AdjustColorFilter adjustColorFilter;

  bool get isMounted => skin != null;

  Future<void> mountNiks(ProjectObservable projectObservable) async {

    this.projectObservable = projectObservable;
    final Project project = projectObservable.value;
    await FileUtils.instance.openProjectEditionBitmapFile(project);
    await FileUtils.instance.openProjectNiksFile(project);
    final width = project.imageSize.width;
    final height = project.imageSize.height;
    skin = Niks.blank(NiksOptions(width: width, height: height));
    skin.installLayer(BitmapLayerInstallation());
    skin.hydrate(project.niksFile.json);

    imageLayer = skin.state.layerByUUID(imageLayerID) as BitmapLayer;

    contrastFilter = imageLayer.filters[contrastFilterID];
    brightnessFilter = imageLayer.filters[brightnessFilterID];
    adjustColorFilter = imageLayer.filters[adjustColorFilterID];

    imageLayer.bitmap = Bitmap(
      project.thumbnailSize.width.toInt(),
      project.thumbnailSize.height.toInt(),
      project.editionBitmapFile.fileData,
    );

    await imageLayer.scheduleImageConversion(skin.state);
    if (isMounted) {
      skin.state.markNeedsPaint();
    }
  }

  void commitAndSave(String saveName) async {
    assert(isMounted);
    final Project project = projectObservable.value;
    final ProjectObservable observable = projectObservable;

    final ProjectNiksFile niksFile = ProjectNiksFile.fromMap(skin.dehydrate());
    final newFile = await ProjectsManager.saveProject(
      project,
      niksFile,
      imageLayer,
    );
    observable.setNewThumbnail(newFile);
  }

  Future<Uint8List> exportImage(Uint8List uInt8list, Size imageSize) async {
    assert(isMounted);

    final width = imageSize.width;
    final height = imageSize.height;

    final skin = Niks.blank(NiksOptions(width: width, height: height));
    skin.installLayer(BitmapLayerInstallation());
    final imageLayer = BitmapLayer.fromLTWH(
      Bitmap(
        width.toInt(),
        height.toInt(),
        uInt8list,
      ),
      0,
      0,
      width,
      height,
    );
    skin.state.addOnTop(imageLayer);

    imageLayer.addFilter(contrastFilterID, contrastFilter);
    imageLayer.addFilter(brightnessFilterID, brightnessFilter);
    imageLayer.addFilter(adjustColorFilterID, adjustColorFilter);

    await imageLayer.scheduleImageConversion(skin.state);

    return await skin.generatePicture(ImageByteFormat.png);
  }

  Future<void> unmountNiks() async {
    skin.dispose();
    projectObservable = null;
    skin = null;
    imageLayer = null;
    contrastFilter = null;
    brightnessFilter = null;
    adjustColorFilter = null;
  }
}
