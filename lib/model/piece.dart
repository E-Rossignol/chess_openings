import 'package:chess_openings/helpers/constants.dart';

class Piece {
  final PieceType type;
  final PieceColor color;
  final int id;
  bool hasMove = false;

  Piece(
      {required this.type,
      required this.color,
      required this.id,
      required this.hasMove});
}
