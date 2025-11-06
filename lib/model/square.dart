import 'package:chess_ouvertures/model/piece.dart';

class Square {
  final int row;
  final int col;
  final bool isWhite;
  Piece? piece;

  Square(this.row, this.col, {this.piece}) : isWhite = (row + col) % 2 == 0;

  Piece? removePiece() {
    final removedPiece = piece;
    piece = null;
    return removedPiece;
  }

  String toStr() {
    return String.fromCharCode(65 + col) + (8 - row).toString();
  }
}
