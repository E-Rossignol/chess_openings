import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants.dart';
import '../model/piece.dart';

class CapturedPiecesComponent extends StatefulWidget {
  List<Piece> capturedPieces;
  CapturedPiecesComponent({super.key, required this.capturedPieces});

  @override
  State<CapturedPiecesComponent> createState() => _CapturedPiecesComponentState();
}

class _CapturedPiecesComponentState extends State<CapturedPiecesComponent> {

  Widget _capturedPieces() {
    Color background = Colors.transparent;
    if (widget.capturedPieces.isNotEmpty) {
      background = widget.capturedPieces.first.color == PieceColor.white ? Colors.grey.shade600.withOpacity(0.8) : Colors.white.withOpacity(0.8);
    }
    widget.capturedPieces.sort((a,b) => pieceValue(a.type).compareTo(pieceValue(b.type)));
    List<Widget> images = widget.capturedPieces.map((piece) {
      return SvgPicture.asset(
        'assets/images/${pieceTypeToSVG(piece.type, piece.color)}',
        width: 30,
        height: 30,
      );
    }).toList();
    return Container(
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: background,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: images,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _capturedPieces();
  }
}
