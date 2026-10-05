import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
  final String databasePath = await getDatabasesPath();

  final String path = join(
    databasePath,
    'floodshield.db',
  );

  return await openDatabase(
    path,
    version: 2,
    onCreate: _createDatabase,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute(
          'ALTER TABLE incidents ADD COLUMN incident_id INTEGER',
        );
      }
    },
  );
}

  Future<void> _createDatabase(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE incidents (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        lat REAL,
        lng REAL,
        severity TEXT,
        description TEXT,
        photo TEXT,
        timestamp TEXT,
        sync_status TEXT,
        zone_id TEXT,
incident_id INTEGER
      )
    ''');
  }

  Future<int> insertIncident(
    Map<String, dynamic> incident,
  ) async {
    final Database db = await database;

    return await db.insert(
      'incidents',
      incident,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getIncidents() async {
    final Database db = await database;

    return await db.query(
      'incidents',
      orderBy: 'timestamp DESC',
    );
  }

  Future<int> updateIncident(
    String id,
    Map<String, dynamic> incident,
  ) async {
    final Database db = await database;

    return await db.update(
      'incidents',
      incident,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteIncident(String id) async {
    final Database db = await database;

    return await db.delete(
      'incidents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<int> deleteAllIncidents() async {
  final Database db = await database;

  return await db.delete('incidents');
}

  Future<List<Map<String, dynamic>>> getPendingIncidents() async {
    final Database db = await database;

    return await db.query(
      'incidents',
      where: 'sync_status = ?',
      whereArgs: ['Pending Sync'],
      orderBy: 'timestamp ASC',
    );
  }
}