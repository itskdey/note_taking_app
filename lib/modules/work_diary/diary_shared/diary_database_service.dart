import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'diary_block_model.dart';
import 'diary_entry_model.dart';

/// Local SQLite persistence for diary entries.
class DiaryDatabaseService {
  DiaryDatabaseService._();

  static final DiaryDatabaseService instance = DiaryDatabaseService._();

  static const _databaseName = 'khtextify_diary.db';
  static const _databaseVersion = 3;
  static const tableEntries = 'diary_entries';

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final databasesPath = await getDatabasesPath();
    final database = await openDatabase(
      path.join(databasesPath, _databaseName),
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableEntries (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL DEFAULT '',
            content TEXT NOT NULL DEFAULT '',
            date TEXT NOT NULL,
            mood_emoji TEXT,
            location TEXT,
            tags TEXT NOT NULL DEFAULT '[]',
            is_bookmarked INTEGER NOT NULL DEFAULT 0,
            is_locked INTEGER NOT NULL DEFAULT 0,
            image_paths TEXT NOT NULL DEFAULT '[]',
            blocks TEXT NOT NULL DEFAULT '[]'
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _addColumnIfMissing(db, 'blocks', "TEXT NOT NULL DEFAULT '[]'");
        }
        if (oldVersion < 3) {
          await _addColumnIfMissing(
            db,
            'is_locked',
            'INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
    _database = database;
    return database;
  }

  static Future<void> _addColumnIfMissing(
    Database db,
    String column,
    String definition,
  ) async {
    final tableInfo = await db.rawQuery('PRAGMA table_info($tableEntries)');
    final exists = tableInfo.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute(
        'ALTER TABLE $tableEntries ADD COLUMN $column $definition',
      );
    }
  }

  Future<List<DiaryEntryModel>> getEntries() async {
    final db = await database;
    final rows = await db.query(tableEntries, orderBy: 'date DESC');
    return rows.map(_fromRow).toList();
  }

  Future<void> upsertEntry(DiaryEntryModel entry) async {
    final db = await database;
    await db.insert(
      tableEntries,
      _toRow(entry),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteEntry(String id) async {
    final db = await database;
    await db.delete(tableEntries, where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _toRow(DiaryEntryModel entry) {
    return {
      'id': entry.id,
      'title': entry.title,
      'content': entry.content,
      'date': entry.date.toIso8601String(),
      'mood_emoji': entry.moodEmoji,
      'location': entry.location,
      'tags': jsonEncode(entry.tags),
      'is_bookmarked': entry.isBookmarked ? 1 : 0,
      'is_locked': entry.isLocked ? 1 : 0,
      'image_paths': jsonEncode(entry.imagePaths),
      'blocks': DiaryBlock.encodeList(entry.blocks),
    };
  }

  DiaryEntryModel _fromRow(Map<String, Object?> row) {
    return DiaryEntryModel(
      id: row['id']! as String,
      title: row['title'] as String? ?? '',
      content: row['content'] as String? ?? '',
      date: DateTime.tryParse(row['date'] as String? ?? '') ?? DateTime.now(),
      moodEmoji: row['mood_emoji'] as String?,
      location: row['location'] as String?,
      tags: _decodeList(row['tags'] as String?),
      isBookmarked: (row['is_bookmarked'] as int? ?? 0) == 1,
      isLocked: (row['is_locked'] as int? ?? 0) == 1,
      imagePaths: _decodeList(row['image_paths'] as String?),
      blocks: DiaryBlock.decodeList(row['blocks'] as String?),
    );
  }

  List<String> _decodeList(String? value) {
    if (value == null || value.isEmpty) return const [];
    try {
      final decoded = jsonDecode(value);
      return decoded is List
          ? decoded.map((item) => item.toString()).toList()
          : const [];
    } on FormatException {
      return const [];
    }
  }
}
