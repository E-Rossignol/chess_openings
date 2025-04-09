import 'package:flutter_svg/svg.dart';

import '../model/openings/opening.dart';
import '../model/openings/opening_move.dart';
import '../model/piece.dart';
import '../model/square.dart';
import 'package:flutter/material.dart';

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

Opening mergeOpenings(List<Opening> openings) {
  // Vérifie que toutes les ouvertures sont jouées par la même couleur
  if (openings.isEmpty) {
    throw ArgumentError('La liste des ouvertures ne peut pas être vide.');
  }
  final PieceColor color = openings.first.color;
  for (var opening in openings) {
    if (opening.color != color) {
      throw ArgumentError('Toutes les ouvertures doivent être jouées par la même couleur.');
    }
  }

  // Fusionne les coups en ajoutant un identifiant d'ouverture
  List<OpeningMove> globalMoves = [];
  for (var opening in openings) {
    for (var move in opening.moves) {
      globalMoves.add(
        OpeningMove(
          openingId: -2,
          id: move.id,
          from: move.from,
          to: move.to,
          moveNumber: move.moveNumber,
          previousMoveId: move.previousMoveId,
          openingName: opening.name, // Ajoute le nom de l'ouverture d'origine
        ),
      );
    }
  }

  // Crée l'ouverture globale
  return Opening(
    name: "Global Opening",
    moves: globalMoves,
    color: color,
  );
}

// Méthode pour identifier l'ouverture d'origine à un moment donné
String? getCurrentOpeningName(Opening globalOpening, int moveNumber, int lastMoveId) {
  for (var move in globalOpening.moves) {
    if (move.moveNumber == moveNumber && move.previousMoveId == lastMoveId) {
      return move.openingName; // Retourne le nom de l'ouverture d'origine
    }
  }
  return null; // Aucun coup correspondant trouvé
}
Color primaryThemeDarkColor = const Color.fromRGBO(14,31,44, 1.0);
Color primaryThemeLightColor = const Color.fromRGBO(242, 239, 229, 1.0);
Color secondaryThemeDarkColor = const Color.fromRGBO(44, 27, 14, 1.0);
Color secondaryThemeLightColor = const Color.fromRGBO(229, 232, 242, 1.0);

Color lighterColor(Color init) {
  int red = init.red;
  int green = init.green;
  int blue = init.blue;
  red + 50 > 255 ? red = 255 : red += 50;
  green + 50 > 255 ? green = 255 : green += 50;
  blue + 50 > 255 ? blue = 255 : blue += 50;
  return Color.fromRGBO(red, green, blue, 1);
}
List<List<Color>> boardColors = [
  [
    const Color.fromRGBO(115, 149, 82, 1),
    const Color.fromRGBO(235, 236, 208, 1),
    const Color.fromRGBO(150, 253, 42, 1.0),
    const Color.fromRGBO(48, 66, 36, 1.0),
  ],
  [
    const Color.fromRGBO(35, 42, 54, 1),
    const Color.fromRGBO(104, 113, 130, 1),
    const Color.fromRGBO(53, 100, 194, 1.0),
    const Color.fromRGBO(18, 21, 28, 1.0),
  ],
  [
    const Color.fromRGBO(184, 135, 98, 1),
    const Color.fromRGBO(237, 214, 176, 1),
    const Color.fromRGBO(232, 135, 69, 1.0),
    const Color.fromRGBO(77, 55, 40, 1.0),
  ],
  [
    const Color.fromRGBO(132, 118, 186, 1),
    const Color.fromRGBO(240, 241, 240, 1),
    const Color.fromRGBO(161, 135, 255, 1.0),
    const Color.fromRGBO(59, 56, 87, 1.0),
  ],
  [
    const Color.fromRGBO(50, 103, 75, 1),
    const Color.fromRGBO(231, 231, 229, 1),
    const Color.fromRGBO(94, 196, 141, 1.0),
    const Color.fromRGBO(25, 51, 36, 1.0),
  ],
  [
    const Color.fromRGBO(75, 115, 153, 1),
    const Color.fromRGBO(234, 233, 210, 1),
    const Color.fromRGBO(100, 174, 241, 1.0),
    const Color.fromRGBO(36, 56, 73, 1.0),
  ],
  [
    const Color.fromRGBO(209, 136, 21, 1),
    const Color.fromRGBO(250, 228, 174, 1.0),
    const Color.fromRGBO(255, 176, 49, 1.0),
    const Color.fromRGBO(94, 63, 10, 1.0),
  ],
  [
    const Color.fromRGBO(187, 87, 70, 1),
    const Color.fromRGBO(245, 219, 195, 1),
    const Color.fromRGBO(255, 115, 94, 1.0),
    const Color.fromRGBO(98, 47, 37, 1.0),
  ],
];
List<Color> displayColors = [
  boardColors[0][0],
  boardColors[1][0],
  boardColors[2][0],
  boardColors[3][0],
  boardColors[4][0],
  boardColors[5][0],
  boardColors[6][0],
  boardColors[7][0],
];
String colorToStr(Color color) {
  if (color == boardColors[0][0]) {
    return 'green';
  }
  if (color == boardColors[1][0]) {
    return 'blue';
  }
  if (color == boardColors[2][0]) {
    return 'brown';
  }
  if (color == boardColors[3][0]) {
    return 'purple';
  }
  if (color == boardColors[4][0]) {
    return 'teal';
  }
  if (color == boardColors[5][0]) {
    return 'orange';
  }
  if (color == boardColors[6][0]) {
    return 'yellow';
  }
  if (color == boardColors[7][0]) {
    return 'red';
  }
  return 'green';
}
List<Color> getColor(String? name) {
  if (name == null) {
    return boardColors[0];
  }
  switch (name) {
    case 'green':
      return boardColors[0];
    case 'blue':
      return boardColors[1];
    case 'brown':
      return boardColors[2];
    case 'purple':
      return boardColors[3];
    case 'teal':
      return boardColors[4];
    case 'orange':
      return boardColors[5];
    case 'yellow':
      return boardColors[6];
    case 'red':
      return boardColors[7];
    default:
      return boardColors[0];
  }
}
List<String> styleNames = [
  'alpha',
  'mpchess',
  'cburnett',
  'kosal',
  'merida',
  'staunty',
  'anarcandy',
  'caliente',
  'california',
  'chess7',
  'chessnut',
  'companion',
  'disguised',
  'dubrovny',
  'fantasy',
  'fresca',
  'gioco',
  'governor',
  'horsey',
  'icpieces',
  'leipzig',
  'letter',
  'maestro',
  'monarchy',
  'pirouetti',
  'pixel',
  'riohacha',
  'rhosgfx',
  'shapes',
  'tatiana',
  'xkcd'
  ];
List<List<SvgPicture>> displayPieces() {
  List<List<SvgPicture>> list = [];
  for (int i = 0; i < styleNames.length; i++) {
    list.add([
      SvgPicture.asset('assets/images/pieces/${styleNames[i]}/wP.svg',
          height: 60, width: 60),
      SvgPicture.asset('assets/images/pieces/${styleNames[i]}/bN.svg',
          height: 60, width: 60),
      SvgPicture.asset('assets/images/pieces/${styleNames[i]}/wB.svg',
          height: 60, width: 60),
      SvgPicture.asset('assets/images/pieces/${styleNames[i]}/bR.svg',
          height: 60, width: 60),
      SvgPicture.asset('assets/images/pieces/${styleNames[i]}/wQ.svg',
          height: 60, width: 60),
      SvgPicture.asset('assets/images/pieces/${styleNames[i]}/bK.svg',
          height: 60, width: 60),
    ]);
  }
  return list;
}
PieceColor toggleColor(PieceColor color) {
  return color == PieceColor.white ? PieceColor.black : PieceColor.white;
}

String pieceTypeToSVG(PieceType type, PieceColor color, String style) {
  if (style == '') {
    style = 'alpha';
  }
  switch (type) {
    case PieceType.pawn:
      return color == PieceColor.white
          ? 'pieces/$style/wP.svg'
          : 'pieces/$style/bP.svg';
    case PieceType.rook:
      return color == PieceColor.white
          ? 'pieces/$style/wR.svg'
          : 'pieces/$style/bR.svg';
    case PieceType.knight:
      return color == PieceColor.white
          ? 'pieces/$style/wN.svg'
          : 'pieces/$style/bN.svg';
    case PieceType.bishop:
      return color == PieceColor.white
          ? 'pieces/$style/wB.svg'
          : 'pieces/$style/bB.svg';
    case PieceType.queen:
      return color == PieceColor.white
          ? 'pieces/$style/wQ.svg'
          : 'pieces/$style/bQ.svg';
    case PieceType.king:
      return color == PieceColor.white
          ? 'pieces/$style/wK.svg'
          : 'pieces/$style/bK.svg';
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

List<String> defaultOpenings() {
  List<String> result = [];
  result.add("Italian");
  result.add('Queen\'s Gambit');
  result.add('Sicilian Defense');
  result.add('Englund\'s Gambit');
  result.add('Scandinavian Defense');
  result.add('Scotch Game');
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

List<String> queensGambitOpening() {
  List<String> result = [];
  result.add("d2d4 d7d5 c2c4 d5c4 e2e3 b7b5 a2a4 b5a4 d1a4 c8d7 a4c4");
  result.add("d2d4 d7d5 c2c4 e7e6");
  return result;
}

List<String> sicilianOpening() {
  List<String> result = [];
  result.add(
      "e2e4 c7c5 g1f3 b8c6 d2d4 c5d4 f3d4 g8f6 b1c3 e7e6 c1e3 f8b4 f2f3 d7d5 d4c6 b7c6 e4e5 f6d7");
  result.add(
      "e2e4 c7c5 g1f3 b8c6 d2d4 c5d4 f3d4 g8f6 b1c3 e7e6 d4c6 b7c6 e4e5 f6d5");
  result.add(
      "e2e4 c7c5 g1f3 b8c6 f1c4 e7e6 e1g1 d7d5 e4d5 e6d5 c4b5 g8f6 d2d4 f8e7");
  return result;
}

List<String> englundOpening() {
  List<String> result = [];
  result.add(
      "d2d4 e7e5 d4e5 b8c6 g1f3 d8e7 c1f4 e7b4 f4d2 b4b2 d2c3 f8b4 d1d2 b4c3 d2c3 b2c1");
  result.add("d2d4 e7e5 d4e5 b8c6 g1f3 d8e7 c1f4 e7b4 c2c3 b4f4");
  result.add("d2d4 e7e5 d4e5 b8c6 g1f3 d8e7 c1f4 e7b4 b1c3 b4f4");
  result.add("d2d4 e7e5 d4e5 b8c6 g1f3 d8e7 c1f4 e7b4 d1d2 b4b2 c2c4 b2a1");
  result.add(
      "d2d4 e7e5 d4e5 b8c6 g1f3 d7d6 c1f4 c8g4 e5d6 d8f6 e2e3 f8d6 f4d6 e8c8 b1c3 d8d6");
  result.add(
      "d2d4 e7e5 d4e5 b8c6 g1f3 d7d6 e5d6 f8d6 e2e3 c8g4 f1e2 d8e7 e1g1 e8c8 b1c3 d6h2 f3h2 d8d1");
  result.add(
      "d2d4 e7e5 d4e5 b8c6 g1f3 d7d6 e5d6 f8d6 e2e3 c8g4 f1e2 d8e7 e1g1 e8c8 b1d2 h7h5 h2h3 g8f6 h3g4 h5g4 f3d4 d6h2 g1h1");
  result.add(
      "d2d4 e7e5 d4e5 b8c6 g1f3 d7d6 e5d6 f8d6 e2e3 c8g4 f1e2 d8e7 e1g1 e8c8 b1d2 h7h5 h2h3 g7g5 h3g4 h5g4 f3d4 d6h2 g1h1 f7f5");
  result.add(
      "d2d4 e7e5 d4e5 b8c6 g1f3 d7d6 e5d6 f8d6 e2e3 c8g4 f1e2 d8e7 e1g1 e8c8 d1e1 h7h5 h2h3 g8f6 h3g4 h5g4 f3d4 d6h2 g1h1 e7e5");
  result.add(
      "d2d4 e7e5 d4e5 b8c6 g1f3 d7d6 e5d6 f8d6 e2e3 c8g4 f1e2 d8e7 e1g1 e8c8 d1e1 h7h5 h2h3 g8f6 b1c3 g4f3 e2f3 e7e5 g2g3 h5h4 g3h4 e5h2");
  result.add(
      "d2d4 e7e5 d4e5 b8c6 g1f3 d7d6 e5d6 f8d6 c1g5 f7f6 g5h4 d8e7 e2e3 c8g4 f1e2 e8c8 e1g1 d6h2 f3h2 d8d1");
  return result;
}

List<String> scandinavianOpening() {
  List<String> result = [];
  result.add('e2e4 d7d5 e4d5 d8d5 b1c3 d5a5 d2d4 c7c6 c1d2 a5c7');
  return result;
}

List<String> scotchOpening(){
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

String indexes(int index, bool isReversed) {
  String res = "";
  // 0,8,16,32,40,48,56,57,58,59,60,61,62,63
  switch (index) {
    case 0:
      res = isReversed ? "1" : "8";
      break;
    case 8:
      res = isReversed ? "2" : "7";
      break;
    case 16:
      res = isReversed ? "3" : "6";
      break;
    case 24:
      res = isReversed ? "4" : "5";
      break;
    case 32:
      res = isReversed ? "5" : "4";
      break;
    case 40:
      res = isReversed ? "6" : "3";
      break;
    case 48:
      res = isReversed ? "7" : "2";
      break;
    case 56:
      res = isReversed ? "8" : "1";
      break;
    case 57:
      res = isReversed ? "g" : "b";
      break;
    case 58:
      res = isReversed ? "f" : "c";
      break;
    case 59:
      res = isReversed ? "e" : "d";
      break;
    case 60:
      res = isReversed ? "d" : "e";
      break;
    case 61:
      res = isReversed ? "c" : "f";
      break;
    case 62:
      res = isReversed ? "b" : "g";
      break;
    case 63:
      res = isReversed ? "a" : "h";
      break;
    default:
      res = "0";
      break;
  }
  return res;
}

List<int> coordinatesIndexes = [
  0,
  8,
  16,
  24,
  32,
  40,
  48,
  56,
  57,
  58,
  59,
  60,
  61,
  62,
  63
];
