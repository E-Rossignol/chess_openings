import 'package:chess_ouvertures/model/square.dart';

class OpeningMove {
  int openingId;
  int id;
  final Square from;
  final int moveNumber;
  final Square to;
  int? previousMoveId;
  String? openingName;

  OpeningMove({
    required this.openingId,
    required this.id,
    required this.from,
    required this.moveNumber,
    required this.to,
    this.previousMoveId,
    this.openingName,
  });

  String toStr() {
    return '${from.toStr()}${to.toStr()}';
  }
}
