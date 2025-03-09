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
}