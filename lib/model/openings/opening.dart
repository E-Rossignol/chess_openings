import '../../constants.dart';
import 'opening_move.dart';

class Opening{
  final String name;
  final PieceColor color;
  List<OpeningMove> moves = [];

  Opening({
    required this.name,
    required this.color,
    required this.moves,
  });

  void addMove(OpeningMove move){
    if (!moves.any((m) => m.id == move.id)) {
      moves.add(move);
    }
  }

  List<OpeningMove>? findNextMove(OpeningMove previousMove){
    return moves.where((element) => element.previousMoveId == previousMove.id ).toList();
  }

  void deleteMove(OpeningMove deletedMove){
    List<OpeningMove> toDeleteMoves = moves.where((element) => element.previousMoveId == deletedMove.id).toList();
    if (toDeleteMoves.isNotEmpty){
      for (OpeningMove sonMove in toDeleteMoves){
        deleteMove(sonMove);
      }
    }
    else {
      moves.remove(deletedMove);
    }
  }

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