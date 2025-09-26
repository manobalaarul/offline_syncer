import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/sync_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'offline_sync.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sync_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        formId TEXT NOT NULL,
        encryptedData TEXT NOT NULL,
        targetRoute TEXT NOT NULL,
        customHeaders TEXT,
        httpMethod TEXT DEFAULT 'POST',
        createdAt INTEGER NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        retryCount INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> insertSyncData(SyncData data) async {
    final db = await database;
    return await db.insert('sync_data', data.toMap());
  }

  Future<List<SyncData>> getUnsyncedData() async {
    final db = await database;
    final maps = await db.query(
      'sync_data',
      where: 'isSynced = ?',
      whereArgs: [0],
      orderBy: 'createdAt ASC',
    );
    return maps.map((map) => SyncData.fromMap(map)).toList();
  }

  Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update(
      'sync_data',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateRetryCount(int id, int retryCount) async {
    final db = await database;
    await db.update(
      'sync_data',
      {'retryCount': retryCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteOldSyncedData({int daysOld = 30}) async {
    final db = await database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: daysOld))
        .millisecondsSinceEpoch;

    await db.delete(
      'sync_data',
      where: 'isSynced = 1 AND createdAt < ?',
      whereArgs: [cutoffTime],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
