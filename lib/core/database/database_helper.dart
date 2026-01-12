import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // 現在のアプリの最新バージョン
  static const int _firstVersion = 1;
  static const int _databaseVersion = 1;
  static const String _filePath = 'kino_note.db';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  final Map<int, List<String>> _migrationScripts = {
    1: [
      '''
      CREATE TABLE trees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        growth_level INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
      ''',
      '''
      CREATE TABLE pages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tree_id INTEGER NOT NULL,
        title TEXT,
        content TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (tree_id) REFERENCES trees (id) ON DELETE CASCADE
      )
      ''',
      '''
      CREATE TABLE growth_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tree_id INTEGER NOT NULL,
        delta_chars INTEGER NOT NULL,
        log_date TEXT NOT NULL,      
        FOREIGN KEY (tree_id) REFERENCES trees (id) ON DELETE CASCADE
      )
      ''',
      '''
      CREATE TRIGGER update_pages_updated_at
      AFTER UPDATE ON pages
      FOR EACH ROW
      BEGIN
          UPDATE pages SET updated_at = DATETIME('now', 'localtime') WHERE id = old.id;
      END
      ''',
      'CREATE INDEX idx_growth_logs_tree_date ON growth_logs(tree_id, log_date)',
    ],
    // 2: ['ALTER TABLE ...'], // 将来の拡張
  };

  Future<Database> _initDB() async {
    final path = await dbPath();

    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        // 初期テーブル作成
        await _executeMigrations(db, _firstVersion, version);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // バージョンアップ時に差分スクリプトを順次実行
        await _executeMigrations(db, oldVersion, newVersion);
      },
    );
  }

  Future<void> deleteExtraFiles() async {
    final path = await dbPath();
    final wal = File('$path-wal');
    final shm = File('$path-shm');
    if (await wal.exists()) await wal.delete();
    if (await shm.exists()) await shm.delete();
  }

  Future<String> dbPath() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _filePath);
    return path;
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> _executeMigrations(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (int i = oldVersion; i <= newVersion; i++) {
      final scripts = _migrationScripts[i];
      if (scripts != null) {
        for (final script in scripts) {
          await db.execute(script);
        }
      }
    }
  }
}
