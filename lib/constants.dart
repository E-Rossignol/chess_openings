
import 'model/openings/opening_move.dart';
import 'model/piece.dart';
import 'model/square.dart';

enum PieceType {
  pawn,
  rook,
  knight,
  bishop,
  queen,
  king,
}

enum PieceColor {
  white,
  black,
}

PieceColor toggleColor(PieceColor color) {
  return color == PieceColor.white ? PieceColor.black : PieceColor.white;
}

String pieceTypeToSVG(PieceType type, PieceColor color) {
  switch (type) {
    case PieceType.pawn:
      return color == PieceColor.white ? 'wP.svg' : 'bP.svg';
    case PieceType.rook:
      return color == PieceColor.white ? 'wR.svg' : 'bR.svg';
    case PieceType.knight:
      return color == PieceColor.white ? 'wN.svg' : 'bN.svg';
    case PieceType.bishop:
      return color == PieceColor.white ? 'wB.svg' : 'bB.svg';
    case PieceType.queen:
      return color == PieceColor.white ? 'wQ.svg' : 'bQ.svg';
    case PieceType.king:
      return color == PieceColor.white ? 'wK.svg' : 'bK.svg';
  }
}

int getValue(Piece piece) {
  int value = 0;
  switch (piece.type) {
    case PieceType.pawn:
      value = 1;
      break;
    case PieceType.rook:
      value = 5;
      break;
    case PieceType.knight:
      value = 3;
      break;
    case PieceType.bishop:
      value = 3;
      break;
    case PieceType.queen:
      value = 10;
      break;
    case PieceType.king:
      value = -1;
      break;
  }
  return value;
}

List<String> toChessCoordinates(int row, int col) {
  return [
    String.fromCharCode(97 + col),
    (8 - row).toString(),
  ];
}

List<int> fromChessCoordinates(String row, String col) {
  return [
    8 - int.parse(col),
    row.codeUnitAt(0) - 97,
  ];
}

int distance(Square square1, Square square2) {
  int rowDistance = (square1.row - square2.row).abs();
  int colDistance = (square1.col - square2.col).abs();
  return rowDistance + colDistance;
}

OpeningMove getMoveFromQuery(Map<String, dynamic> moveQuery) {
  OpeningMove move = OpeningMove(
      openingId: moveQuery['id_table'],
      id: moveQuery['id'],
      from: stringToSquare(moveQuery['start_square']),
      to: stringToSquare(moveQuery['end_square']),
      moveNumber: moveQuery['move_nbr'],
      previousMoveId: moveQuery['is_after']);
  return move;
}

Map<String, dynamic> getQueryFromMove(OpeningMove move) {
  return {
    'id_table': move.openingId,
    'id': move.id,
    'start_square': squareToString(move.from),
    'end_square': squareToString(move.to),
    'move_nbr': move.moveNumber,
    'is_after': move.previousMoveId
  };
}

Square stringToSquare(String position) {
  int col = position.codeUnitAt(0) - 97; // Convertit 'a'-'h' en 0-7
  int row = 8 - int.parse(position[1]); // Convertit '1'-'8' en 7-0
  return Square(row, col);
}

String squareToString(Square square) {
  String col = String.fromCharCode(97 + square.col); // Convertit 0-7 en 'a'-'h'
  String row = (8 - square.row).toString(); // Convertit 7-0 en '1'-'8'
  return col + row;
}

List<String> defaultOpenings(){
  List<String> result = [];
  result.add("Italian");
  result.add('Queen\'s Gambit');
  result.add('Sicilian Defense');
  result.add('French Defense');
  result.add('Englund\'s Gambit');
  return result;
}

List<String> italianOpening() {
  List<String> result = [];
  result.add(
      'e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 d2d3 f8c5 b1c3 e8g8 c1g5 h7h6 g5f6 d8f6 c3d5 f6e6 d5c7 e6g6 c7a8');
  result.add(
      'e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 d2d3 f8c5 b1c3 d7d6 c1g5 e8g8 c3d5 f6d5 g5d8');
  result.add(
      'e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 d2d3 f8c5 b1c3 d7d6 c1g5 e8g8 c3d5 c8e6 d5f6 g7f6 g5h6 f8e8');
  result.add(
      'e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 d2d3 f8c5 b1c3 d7d6 c1g5 e8g8 c3d5 c8g4 d1d2 g4f3 g5f6 g7f6 d2h6 f3g4 d5f6 g8h8 h7h6');
  result.add(
      'e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 d2d3 f8c5 b1c3 d7d6 c1g5 e8g8 c3d5 d8e8 g5f6 g7f6 d5f6 g8h8 f6e8');
  result.add(
      'e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 d2d3 f8c5 b1c3 d7d6 c1g5 e8g8 c3d5 h7h6 d5f6 g7f6 g5h6');
  result.add(
      'e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 d2d3 f8c5 b1c3 d7d6 c1g5 h7h6 g5f6 g7f6 c3d5');
  result.add(
      'e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 d2d3 f8c5 b1c3 f6g4 c4f7 e8f7 f3g5 f7g8 d1g4');
  result.add('e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 d2d3 f8d6 b1c3');
  return result;
}

List<String> queensGambitOpening(){
  List<String> result = [];
  return result;
}

List<String> frenchOpening(){
  List<String> result = [];
  return result;
}

List<String> sicilianOpening(){
  List<String> result = [];
  return result;
}

List<String> englundOpening(){
  List<String> result = [];

  return result;
}

int pieceValue(PieceType type) {
  switch (type) {
    case PieceType.pawn:
      return 1;
    case PieceType.rook:
      return 5;
    case PieceType.knight:
      return 3;
    case PieceType.bishop:
      return 3;
    case PieceType.queen:
      return 9;
    case PieceType.king:
      return 0;
  }
}