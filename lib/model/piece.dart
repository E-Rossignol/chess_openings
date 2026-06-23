import 'package:chess_openings/helpers/constants.dart';

/// Represents a chess piece with type, color and identity.
///
/// @param type piece type (pawn, knight, ...)
/// @param color piece color (white or black)
/// @param id unique identifier used to track the piece instance
/// @param hasMove whether the piece has already moved (affects castling, etc.)
class Piece {
  final PieceType type;
  final PieceColor color;
  final int id;
  bool hasMove = false;

  /// Creates a Piece.
  ///
  /// @param type piece type
  /// @param color piece color
  /// @param id unique id
  /// @param hasMove initial moved state
  Piece({
    required this.type,
    required this.color,
    required this.id,
    required this.hasMove,
  });
}
