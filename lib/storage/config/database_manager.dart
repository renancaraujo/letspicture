import 'package:flutter/services.dart';
import 'package:letspicture/storage/project/project_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const dbname = "letspicture";
const int version = 1;

class DatabaseManager {
  DatabaseManager._internal();

  static DatabaseManager _instance;

  static DatabaseManager get instance {
    _instance ??= DatabaseManager._internal();
    return _instance;
  }

  Database db;

  Future init() async {
    await Future.delayed(Duration(milliseconds: 500));
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, '$dbname.db');
    db = await openDatabase(path, version: version, onCreate: _onCreate);
    return;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(ProjectRepository.createTableScript);
  }
}
