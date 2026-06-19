import 'package:flutter/material.dart';
import '../model/openings/opening_move.dart';
import '../model/square.dart';

/// Custom painter that draws arrows representing moves on an 8x8 board.
///
/// @param moves list of OpeningMove objects to render as arrows (nullable)
/// @param isReversed whether board coordinates should be reversed
/// @param color arrow stroke color
class ArrowPainter extends CustomPainter {
  final List<OpeningMove>? moves;
  final bool isReversed;
  Color color;

  /// Constructor for ArrowPainter.
  ///
  /// @param moves list of moves to draw (may be null)
  /// @param isReversed whether coordinates are reversed
  /// @param color color of the arrow lines
  ArrowPainter(
      {required this.moves, required this.isReversed, required this.color});

  /// Paints lines and arrow heads for each move.
  ///
  /// @param canvas drawing canvas
  /// @param size available canvas size
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    if (moves == null) {
      return;
    }
    for (var move in moves!) {
      final fromOffset = _getSquareCenter(move.from, size);
      final toOffset = _getSquareCenter(move.to, size);
      canvas.drawLine(fromOffset, toOffset, paint);
      _drawArrowHead(canvas, paint, fromOffset, toOffset);
    }
  }

  /// Computes the center Offset of a square for the given canvas size.
  ///
  /// @param square Square object
  /// @param size canvas size
  /// @return Offset center of the square
  Offset _getSquareCenter(Square square, Size size) {
    final squareSize = size.width / 8;
    final row = isReversed ? 7 - square.row : square.row;
    final col = isReversed ? 7 - square.col : square.col;
    return Offset(
        col * squareSize + squareSize / 2, row * squareSize + squareSize / 2);
  }

  /// Draws an arrow head at the target coordinate.
  ///
  /// @param canvas drawing canvas
  /// @param paint paint configuration
  /// @param from start offset
  /// @param to end offset where arrow tip is drawn
  void _drawArrowHead(Canvas canvas, Paint paint, Offset from, Offset to) {
    const arrowHeadSize = 10.0;
    const branchLength = 5.0;
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

  /// Always repaint for simplicity (could be optimized).
  ///
  /// @param oldDelegate previous painter
  /// @return bool whether to repaint
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
