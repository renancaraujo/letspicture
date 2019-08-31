import 'package:letspicture_app/storage/project/project_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

String dbname = "letspicture";
int version = 1;

class DatabaseManager {
  DatabaseManager._internal();

  static DatabaseManager _instance;

  static DatabaseManager get instance {
    if (_instance == null) {
      _instance = DatabaseManager._internal();
    }
    return _instance;
  }

  Database db;

  Future init() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, '$dbname.db');
    db = await openDatabase(path, version: version, onCreate: _onCreate);
    return;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(ProjectRepository.createTableScript);
  }
}
