import 'dart:async';
import 'package:chess_ouvertures/constants.dart';
import 'package:chess_ouvertures/model/openings/opening_move.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/openings/opening.dart';
import '../model/square.dart';

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
        is_after INTEGER,
        variantName TEXT
      )
    ''');
  }

  Future<bool> insertOpening(String openingName, String pieceColor) async {
    final db = await database;
    await db.insert(
      'opening_names',
      {'opening_name': openingName, 'piece_color': pieceColor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  Future<bool> editOpening(int openingID, String openingName, String pieceColor) async {
    final db = await database;
    int count = await db.update(
      'opening_names',
      {'opening_name': openingName, 'piece_color': pieceColor},
      where: 'id = ?',
      whereArgs: [openingID],
    );
    return count > 0;
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
    int? id = await getOpeningIdByName(openingName);
    if (id != null){
      await db.delete('opening_moves',
      where: 'id_table = ?',
      whereArgs: [id],
      );
      await db.delete(
        'opening_names',
        where: 'opening_name = ?',
        whereArgs: [openingName],
      );
    }
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

  Future<int?> getOpeningIdByName(String openingName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'opening_names',
      columns: ['id'],
      where: 'opening_name = ?',
      whereArgs: [openingName],
    );
    if (maps.isNotEmpty) {
      return maps.first['id'] as int;
    } else {
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

  Future<List<OpeningMove>?> insertVariant(List<List<Square>> newVariant, String openingName, String variantName) async{
    Opening? op = await getOpeningByName(openingName);
    int? openingID = await getOpeningIdByName(openingName);
    int lastMoveId = -1;
    if(op == null || openingID == null){
      return null;
    }
    List<OpeningMove> newMoves = [];
    for (List<Square> move in newVariant){
      if (move[0].row == -1 || move[1].row == -1 || move[0].col == -1 || move[1].col == -1 ){
        continue;
      }
      newMoves.add(OpeningMove(from: move[0], to: move[1], moveNumber: newVariant.indexOf(move), openingId: openingID, id: -1));
    }
    int counter = 0;
    bool keepGoing = true;
    while(keepGoing){
      List<OpeningMove> opmv = op.moves.where((element) => element.moveNumber == counter &&
          element.from.row == newMoves[counter].from.row &&
          element.from.col == newMoves[counter].from.col &&
          element.to.row == newMoves[counter].to.row &&
          element.to.col == newMoves[counter].to.col
      ).toList();
      if (opmv.isNotEmpty) {
        newMoves[counter].openingId = -1;
        keepGoing = true;
        lastMoveId = opmv.first.id;
      }
      else {
        keepGoing = false;
      }
      counter ++;
    }
    // THE VARIANT IS NEW FROM HERE
    newMoves.removeWhere((element) => element.openingId == -1);
    newMoves.first.variantName = variantName;
    final db = await database;
    int newMoveId = lastMoveId;
    List<OpeningMove> result = [];
      for (int i = 0; i < newMoves.length; i++){
        int tmp = newMoveId;
        newMoveId = await db.insert(
          'opening_moves',
          {
            'id_table': openingID,
            'move_nbr': newMoves[i].moveNumber,
            'start_square': squareToString(newMoves[i].from),
            'end_square': squareToString(newMoves[i].to),
            'is_after': tmp,
            'variantName': newMoves[i].variantName
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        newMoves[i].previousMoveId = tmp;
        newMoves[i].id = newMoveId;
        result.add(newMoves[i]);
      }

    return result;
  }
}