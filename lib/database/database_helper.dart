import 'dart:async';
import 'package:chess_ouvertures/constants.dart';
import 'package:chess_ouvertures/model/openings/opening_move.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/openings/opening.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        var res1 = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='opening_names'");
        var res2 = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='opening_moves'");
        if (res1.isEmpty || res2.isEmpty) {
          await _onCreate(db, 1);
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE opening_names (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        opening_name TEXT,
        piece_color TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE opening_moves (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_table INTEGER,
        move_nbr INTEGER,
        start_square TEXT,
        end_square TEXT,
        is_after INTEGER
      )
    ''');
  }

  Future<bool> insertOpening(String openingName, String pieceColor) async {
    final db = await database;
    int id = await db.insert(
      'opening_names',
      {'opening_name': openingName, 'piece_color': pieceColor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    int moveId = await db.insert(
      'opening_moves',
      {
        'id_table': id,
        'move_nbr': 0,
        'start_square': 'e2',
        'end_square': 'e4',
        'is_after': null
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    int moveId1 = await db.insert(
      'opening_moves',
      {
        'id_table': id,
        'move_nbr': 1,
        'start_square': 'e7',
        'end_square': 'e5',
        'is_after': moveId
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    int moveId2 = await db.insert(
      'opening_moves',
      {
        'id_table': id,
        'move_nbr': 1,
        'start_square': 'e7',
        'end_square': 'e4',
        'is_after': moveId
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'opening_moves',
      {
        'id_table': id,
        'move_nbr': 2,
        'start_square': 'e5',
        'end_square': 'b5',
        'is_after': moveId1
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'opening_moves',
      {
        'id_table': id,
        'move_nbr': 2,
        'start_square': 'e5',
        'end_square': 'a5',
        'is_after': moveId1
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'opening_moves',
      {
        'id_table': id,
        'move_nbr': 2,
        'start_square': 'e4',
        'end_square': 'f5',
        'is_after': moveId2
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'opening_moves',
      {
        'id_table': id,
        'move_nbr': 2,
        'start_square': 'e5',
        'end_square': 'e8',
        'is_after': moveId2
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }
  Future<List<String>> getOpeningsNames() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
        'opening_names', columns: ['opening_name']);
    return List.generate(maps.length, (i) {
      return maps[i]['opening_name'] as String;
    });
  }

  Future<bool> resetTables() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS opening_names');
    await db.execute('DROP TABLE IF EXISTS opening_moves');
    await _onCreate(db, 1);
    return true;
  }

  Future<void> deleteOpening(String openingName) async {
    final db = await database;
    await db.delete(
      'opening_names',
      where: 'opening_name = ?',
      whereArgs: [openingName],
    );
  }

  Future<Opening?> getOpeningByName(String openingName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'opening_names',
      columns: ['id', 'opening_name', 'piece_color'],
      where: 'opening_name = ?',
      whereArgs: [openingName],
    );
    if (maps.isNotEmpty) {
      List<Map<String, dynamic>> moves = await getMovesByOpeningId(maps.first['id']);
      List<OpeningMove> openingMoves = [];
      for (Map<String, dynamic> move in moves){
        openingMoves.add(getMoveFromQuery(move));
      }
      return Opening(name: maps.first['opening_name'], moves: openingMoves, color: maps.first['piece_color'] == 'white' ? PieceColor.white : PieceColor.black);
    }
    else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMovesByOpeningId(int openingId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'opening_moves',
      where: 'id_table = ?',
      whereArgs: [openingId],
    );
    return maps;
  }
}