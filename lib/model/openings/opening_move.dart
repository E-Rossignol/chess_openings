import 'package:chess_ouvertures/model/square.dart';

class OpeningMove {
  final int openingId;
  final int id;
  final Square from;
  final int moveNumber;
  final Square to;
  final int? previousMoveId;

  OpeningMove({
    required this.openingId,
    required this.id,
    required this.from,
    required this.moveNumber,
    required this.to,
    this.previousMoveId,
  });
}