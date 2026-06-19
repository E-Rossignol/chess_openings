import '../../helpers/constants.dart';
import 'opening_move.dart';

/// Represents a chess opening containing a name, color and a list of moves.
///
/// @param name the name of the opening
/// @param color the color associated with this opening
/// @param moves list of OpeningMove objects that belong to this opening
class Opening {
  final String name;
  final PieceColor color;
  List<OpeningMove> moves = [];

  /// Creates an Opening instance.
  ///
  /// @param name opening name
  /// @param color opening color
  /// @param moves initial list of moves
  Opening({
    required this.name,
    required this.color,
    required this.moves,
  });

  /// Adds a move to the opening if it is not already present.
  ///
  /// @param move OpeningMove to add
  void addMove(OpeningMove move) {
    if (!moves.any((m) => m.id == move.id)) {
      moves.add(move);
    }
  }

  /// Finds next moves that follow the given previous move.
  ///
  /// @param previousMove the move to find successors for
  /// @return list of OpeningMove or null when none found
  List<OpeningMove>? findNextMove(OpeningMove previousMove) {
    return moves
        .where((element) => element.previousMoveId == previousMove.id)
        .toList();
  }

  /// Recursively deletes a move and its descendant moves from the opening.
  ///
  /// @param deletedMove the root move to delete
  void deleteMove(OpeningMove deletedMove) {
    List<OpeningMove> toDeleteMoves = moves
        .where((element) => element.previousMoveId == deletedMove.id)
        .toList();
    if (toDeleteMoves.isNotEmpty) {
      for (OpeningMove sonMove in toDeleteMoves) {
        deleteMove(sonMove);
      }
    } else {
      moves.remove(deletedMove);
    }
  }

  /// Converts all move branches into string representations (lowercased).
  ///
  /// @return list of string sequences representing each branch of the opening
  List<String> toStr() {
    List<String> result = [];
    void dfs(OpeningMove move, String path) {
      String newPath = path.isEmpty ? move.toStr() : '$path ${move.toStr()}';
      List<OpeningMove> nextMoves = findNextMove(move) ?? [];
      if (nextMoves.isEmpty) {
        result.add(newPath);
      } else {
        for (OpeningMove nextMove in nextMoves) {
          dfs(nextMove, newPath);
        }
      }
    }

    for (OpeningMove move in moves.where((m) => m.previousMoveId == -1)) {
      dfs(move, '');
    }
    for (int i = 0; i < result.length; i++) {
      result[i] = result[i].toLowerCase();
    }
    return result;
  }
}
