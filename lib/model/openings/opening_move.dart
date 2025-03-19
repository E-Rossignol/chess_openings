import 'package:chess_ouvertures/model/square.dart';
import 'package:chess_ouvertures/constants.dart';

class OpeningMove {
  int openingId;
  int id;
  final Square from;
  final int moveNumber;
  final Square to;
  int? previousMoveId;

  OpeningMove({
    required this.openingId,
    required this.id,
    required this.from,
    required this.moveNumber,
    required this.to,
    this.previousMoveId,
  });

  String toStr(){
    return '${from.toStr()}${to.toStr()}';
  }
}
