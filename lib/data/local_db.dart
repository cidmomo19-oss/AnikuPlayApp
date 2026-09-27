import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/download_item.dart';
import 'models/watch_history.dart';

class LocalDb {
  static final LocalDb instance = LocalDb._init();
  static Database? _database;

  LocalDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('anikuplay.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bookmarks (
        anime_id INTEGER PRIMARY KEY,
        cached_json TEXT,
        created_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE watch_history (
        anime_id INTEGER PRIMARY KEY,
        episode_number INTEGER,
        position_ms INTEGER,
        duration_ms INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE anilist_cache (
        anilist_id INTEGER PRIMARY KEY,
        json TEXT,
        fetched_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        anime_id INTEGER,
        anime_title TEXT,
        episode_number INTEGER,
        file_path TEXT,
        downloaded_at INTEGER
      )
    ''');
  }

  // --- Bookmarks DAO ---
  Future<void> toggleBookmark(int animeId, String cachedJson) async {
    final db = await instance.database;
    final exists = await isBookmarked(animeId);
    if (exists) {
      await db.delete('bookmarks', where: 'anime_id = ?', whereArgs: [animeId]);
    } else {
      await db.insert('bookmarks', {
        'anime_id': animeId,
        'cached_json': cachedJson,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Future<bool> isBookmarked(int animeId) async {
    final db = await instance.database;
    final res = await db.query(
      'bookmarks',
      where: 'anime_id = ?',
      whereArgs: [animeId],
    );
    return res.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await instance.database;
    return await db.query('bookmarks', orderBy: 'created_at DESC');
  }

  // --- Watch History DAO ---
  Future<void> saveWatchHistory(WatchHistory history) async {
    final db = await instance.database;
    await db.insert(
      'watch_history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<WatchHistory?> getWatchHistory(int animeId) async {
    final db = await instance.database;
    final res = await db.query(
      'watch_history',
      where: 'anime_id = ?',
      whereArgs: [animeId],
    );
    if (res.isNotEmpty) {
      return WatchHistory.fromMap(res.first);
    }
    return null;
  }

  Future<List<WatchHistory>> getAllWatchHistory() async {
    final db = await instance.database;
    final res = await db.query('watch_history', orderBy: 'updated_at DESC');
    return res.map((map) => WatchHistory.fromMap(map)).toList();
  }

  Future<void> deleteWatchHistory(int animeId) async {
    final db = await instance.database;
    await db.delete('watch_history', where: 'anime_id = ?', whereArgs: [animeId]);
  }

  Future<void> clearAllWatchHistory() async {
    final db = await instance.database;
    await db.delete('watch_history');
  }

  // --- AniList Cache DAO ---
  Future<void> cacheAniListMedia(int anilistId, String jsonStr) async {
    final db = await instance.database;
    await db.insert(
      'anilist_cache',
      {
        'anilist_id': anilistId,
        'json': jsonStr,
        'fetched_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getCachedAniListMedia(int anilistId) async {
    final db = await instance.database;
    final res = await db.query(
      'anilist_cache',
      where: 'anilist_id = ?',
      whereArgs: [anilistId],
    );
    if (res.isNotEmpty) {
      return res.first['json'] as String?;
    }
    return null;
  }

  // --- Downloads DAO ---
  Future<int> insertDownload(DownloadItem download) async {
    final db = await instance.database;
    return await db.insert('downloads', download.toMap());
  }

  Future<List<DownloadItem>> getAllDownloads() async {
    final db = await instance.database;
    final res = await db.query('downloads', orderBy: 'downloaded_at DESC');
    return res.map((map) => DownloadItem.fromMap(map)).toList();
  }

  Future<DownloadItem?> getDownload(int animeId, int episodeNumber) async {
    final db = await instance.database;
    final res = await db.query(
      'downloads',
      where: 'anime_id = ? AND episode_number = ?',
      whereArgs: [animeId, episodeNumber],
    );
    if (res.isNotEmpty) {
      return DownloadItem.fromMap(res.first);
    }
    return null;
  }

  Future<void> deleteDownload(int id) async {
    final db = await instance.database;
    await db.delete('downloads', where: 'id = ?', whereArgs: [id]);
  }
}
