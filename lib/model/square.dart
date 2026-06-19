import 'package:chess_openings/model/piece.dart';

/// Represents a square on the chessboard containing optional piece and coordinates.
///
/// @param row zero-based row index (0..7)
/// @param col zero-based column index (0..7)
/// @param isWhite true when square background color is white (computed)
/// @param piece optional Piece located on this square
class Square {
  final int row;
  final int col;
  final bool isWhite;
  Piece? piece;

  /// Creates a Square with computed color parity.
  ///
  /// @param row row index
  /// @param col column index
  /// @param piece optional initial piece
  Square(this.row, this.col, {this.piece}) : isWhite = (row + col) % 2 == 0;

  /// Removes and returns the piece currently on this square.
  ///
  /// @return removed Piece or null if none
  Piece? removePiece() {
    final removedPiece = piece;
    piece = null;
    return removedPiece;
  }

  /// Returns a human-readable coordinate like 'A1'..'H8'.
  ///
  /// @return string coordinate
  String toStr() {
    return String.fromCharCode(65 + col) + (8 - row).toString();
  }
}
