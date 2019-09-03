import 'package:flutter/widgets.dart';
import 'package:letspicture/config/config.dart' as config;
import 'package:letspicture/storage/config/database_manager.dart';
import 'package:letspicture/storage/project/project_file.dart';
import 'package:sqflite/sqlite_api.dart';

class Project {
  Project.createTransient({
    this.importDate,
    this.creationDate,
    this.imageSize,
  });

  Project.fromMap(Map<String, dynamic> map) {
    id = map[idColumn];
    importDate = DateTime.parse(map[importDateColumn]);
    creationDate = DateTime.parse(map[creationDateColumn]);
    imageSize = Size(map[imageWidthColumn] / 1, map[imageHeightColumn] / 1);
    thumbnailSize =
        Size(map[thumbnailWidthColumn] / 1, map[thumbnailHeightColumn] / 1);
  }

  static String tableName = "Project";

  static String idColumn = "id";
  static String importDateColumn = "importDate";
  static String creationDateColumn = "creationDate";
  static String imageWidthColumn = "imageWidth";
  static String imageHeightColumn = "imageHeight";

  static String thumbnailWidthColumn = "thumbnailWidth";
  static String thumbnailHeightColumn = "thumbnailHeight";

  int id;

  DateTime importDate;
  DateTime creationDate;
  Size imageSize;
  Size thumbnailSize;

  Size get miniSize {
    if (config.miniLongestSide > thumbnailSize.longestSide)
      return thumbnailSize;
    final double ratio = config.miniLongestSide / thumbnailSize.longestSide;
    return thumbnailSize * ratio;
  }

  ProjectOriginalBitmapFile originalBitmapFile;
  ProjectThumbnailFile thumbnailFile;
  ProjectEditionBitmapFile editionBitmapFile;
  ProjectNiksFile niksFile;

  bool get isTransient {
    return id == null;
  }

  Future persist() async {
    if (thumbnailSize == null) {
      throw Error();
    } // Todo: improve error
    if (isTransient) {
      await ProjectRepository.insert(this);
    } else {
      await ProjectRepository.update(this);
    }
  }

  Future delete() async {
    await ProjectRepository.delete(this);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      importDateColumn: importDate.toIso8601String(),
      creationDateColumn: creationDate.toIso8601String(),
      imageWidthColumn: imageSize.width,
      imageHeightColumn: imageSize.height,
      thumbnailWidthColumn: thumbnailSize.width,
      thumbnailHeightColumn: thumbnailSize.height
    };
    if (!isTransient) {
      map[idColumn] = id;
    }
    return map;
  }
}

// ignore: avoid_classes_with_only_static_members
class ProjectRepository {
  static Database get _db {
    return DatabaseManager.instance.db;
  }

  static String get createTableScript {
    return '''
      create table  ${Project.tableName} (
        ${Project.idColumn} integer primary key autoincrement,
         
        ${Project.importDateColumn} text not null,
        ${Project.creationDateColumn} text not null,
        
        ${Project.imageWidthColumn} integer not null,
        ${Project.imageHeightColumn} integer not null,
        
        ${Project.thumbnailWidthColumn} integer not null,
        ${Project.thumbnailHeightColumn} integer not null
        )
    ''';
  }

  static Future<List<Project>> allProjects() async {
    final List<Map<String, dynamic>> records =
        await _db.query(Project.tableName);

    return records.map<Project>((Map<String, dynamic> map) {
      return Project.fromMap(map);
    }).toList();
  }

  static Future<Project> insert(Project project) async {
    project.id = await _db.insert(Project.tableName, project.toMap());
    return project;
  }

  static Future<void> delete(Project project) async {
    assert(!project.isTransient);
    await _db.delete(Project.tableName,
        where: '${Project.idColumn} = ?', whereArgs: [project.id]);
  }

  static Future<int> update(Project project) async {
    assert(!project.isTransient);
    return await _db.update(Project.tableName, project.toMap(),
        where: '${Project.idColumn} = ?', whereArgs: [project.id]);
  }
}
