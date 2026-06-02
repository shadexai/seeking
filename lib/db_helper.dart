import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class Idea {
  final String id;
  String title;
  String description;
  String category;
  List<String> tags;
  int mood;
  bool pinned;
  DateTime createdAt;

  Idea({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tags,
    required this.mood,
    required this.pinned,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'tags': tags.join(','),
        'mood': mood,
        'pinned': pinned ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Idea.fromMap(Map<String, dynamic> m) => Idea(
        id: m['id'],
        title: m['title'],
        description: m['description'],
        category: m['category'],
        tags: (m['tags'] as String).isEmpty
            ? []
            : (m['tags'] as String).split(','),
        mood: m['mood'],
        pinned: m['pinned'] == 1,
        createdAt: DateTime.parse(m['createdAt']),
      );
}

class SavedSong {
  final String id;
  String path;
  String name;
  bool isVideo;
  DateTime addedAt;

  SavedSong({
    required this.id,
    required this.path,
    required this.name,
    required this.isVideo,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'path': path,
        'name': name,
        'isVideo': isVideo ? 1 : 0,
        'addedAt': addedAt.toIso8601String(),
      };

  factory SavedSong.fromMap(Map<String, dynamic> m) => SavedSong(
        id: m['id'],
        path: m['path'],
        name: m['name'],
        isVideo: m['isVideo'] == 1,
        addedAt: DateTime.parse(m['addedAt']),
      );
}

class Playlist {
  final String id;
  String name;
  List<String> songPaths;
  DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.songPaths,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'songPaths': songPaths.join(','),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Playlist.fromMap(Map<String, dynamic> m) => Playlist(
        id: m['id'],
        name: m['name'],
        songPaths: (m['songPaths'] as String).isEmpty
            ? []
            : (m['songPaths'] as String).split(','),
        createdAt: DateTime.parse(m['createdAt']),
      );
}

// ─── Database Helper ──────────────────────────────────────────────────────────

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'seeking.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE ideas (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            category TEXT,
            tags TEXT,
            mood INTEGER,
            pinned INTEGER DEFAULT 0,
            createdAt TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE songs (
            id TEXT PRIMARY KEY,
            path TEXT NOT NULL,
            name TEXT NOT NULL,
            isVideo INTEGER DEFAULT 0,
            addedAt TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE playlists (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            songPaths TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  // ── Ideas ──────────────────────────────────────────────────────────────────

  static Future<List<Idea>> getIdeas() async {
    final d = await db;
    final rows = await d.query('ideas', orderBy: 'createdAt DESC');
    return rows.map(Idea.fromMap).toList();
  }

  static Future<void> insertIdea(Idea idea) async {
    final d = await db;
    await d.insert('ideas', idea.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateIdea(Idea idea) async {
    final d = await db;
    await d.update('ideas', idea.toMap(),
        where: 'id = ?', whereArgs: [idea.id]);
  }

  static Future<void> deleteIdea(String id) async {
    final d = await db;
    await d.delete('ideas', where: 'id = ?', whereArgs: [id]);
  }

  // ── Songs ──────────────────────────────────────────────────────────────────

  static Future<List<SavedSong>> getSongs() async {
    final d = await db;
    final rows = await d.query('songs', orderBy: 'addedAt DESC');
    return rows.map(SavedSong.fromMap).toList();
  }

  static Future<void> insertSong(SavedSong song) async {
    final d = await db;
    await d.insert('songs', song.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> deleteSong(String id) async {
    final d = await db;
    await d.delete('songs', where: 'id = ?', whereArgs: [id]);
  }

  static Future<bool> songExists(String path) async {
    final d = await db;
    final rows =
        await d.query('songs', where: 'path = ?', whereArgs: [path]);
    return rows.isNotEmpty;
  }

  // ── Playlists ──────────────────────────────────────────────────────────────

  static Future<List<Playlist>> getPlaylists() async {
    final d = await db;
    final rows = await d.query('playlists', orderBy: 'createdAt DESC');
    return rows.map(Playlist.fromMap).toList();
  }

  static Future<void> insertPlaylist(Playlist pl) async {
    final d = await db;
    await d.insert('playlists', pl.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updatePlaylist(Playlist pl) async {
    final d = await db;
    await d.update('playlists', pl.toMap(),
        where: 'id = ?', whereArgs: [pl.id]);
  }

  static Future<void> deletePlaylist(String id) async {
    final d = await db;
    await d.delete('playlists', where: 'id = ?', whereArgs: [id]);
  }
}
