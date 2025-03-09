import 'package:flutter/material.dart';
import 'model/openings/opening_move.dart';
import 'model/square.dart';

class ArrowPainter extends CustomPainter {
  final List<OpeningMove>? moves;
  final bool isReversed;

  ArrowPainter({required this.moves, required this.isReversed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurpleAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    if (moves == null){
      return;
    }
    for (var move in moves!) {
      final fromOffset = _getSquareCenter(move.from, size);
      final toOffset = _getSquareCenter(move.to, size);
      canvas.drawLine(fromOffset, toOffset, paint);
      _drawArrowHead(canvas, paint, fromOffset, toOffset);
    }
  }

  Offset _getSquareCenter(Square square, Size size) {
    final squareSize = size.width / 8;
    final row = isReversed ? 7 - square.row : square.row;
    final col = isReversed ? 7 - square.col : square.col;
    return Offset(col * squareSize + squareSize / 2, row * squareSize + squareSize / 2);
  }

  void _drawArrowHead(Canvas canvas, Paint paint, Offset from, Offset to) {
    const arrowHeadSize = 10.0;
    const branchLength = 5.0; // Longueur des branches de la tête de la flèche
    final angle = (to - from).direction;
    final arrowHead1 = to - Offset.fromDirection(angle + 0.5, branchLength);
    final arrowHead2 = to - Offset.fromDirection(angle - 0.5, branchLength);
    final arrowHeadTip1 = to - Offset.fromDirection(angle + 0.5, arrowHeadSize);
    final arrowHeadTip2 = to - Offset.fromDirection(angle - 0.5, arrowHeadSize);
    canvas.drawLine(to, arrowHead1, paint);
    canvas.drawLine(to, arrowHead2, paint);
    canvas.drawLine(arrowHead1, arrowHeadTip1, paint);
    canvas.drawLine(arrowHead2, arrowHeadTip2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}