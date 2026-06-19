import 'package:chess_openings/model/square.dart';

/// Represents a single move of an opening, linking squares and move metadata.
///
/// @param openingId database id of the opening this move belongs to
/// @param id unique id of the move
/// @param from origin square
/// @param to destination square
/// @param moveNumber move order number
/// @param previousMoveId id of the previous move (-1 for root)
/// @param openingName optional opening name associated to this move
class OpeningMove {
  int openingId;
  int id;
  final Square from;
  final int moveNumber;
  final Square to;
  int? previousMoveId;
  String? openingName;

  /// Creates an OpeningMove.
  ///
  /// @param openingId id of the opening
  /// @param id unique move id
  /// @param from origin square
  /// @param moveNumber numeric move index
  /// @param to destination square
  /// @param previousMoveId optional previous move id
  /// @param openingName optional opening name
  OpeningMove({
    required this.openingId,
    required this.id,
    required this.from,
    required this.moveNumber,
    required this.to,
    this.previousMoveId,
    this.openingName,
  });

  /// Returns the algebraic concatenation of origin and destination (e.g. e2e4).
  ///
  /// @return string representation of the move
  String toStr() {
    return '${from.toStr()}${to.toStr()}';
  }
}
