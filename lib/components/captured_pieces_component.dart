import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';
import '../model/piece.dart';

/// Widget displaying a horizontal list of captured pieces as SVG images.
///
/// @param capturedPieces list of Piece instances that were captured
class CapturedPiecesComponent extends StatefulWidget {
  List<Piece> capturedPieces;
  CapturedPiecesComponent({super.key, required this.capturedPieces});

  @override
  State<CapturedPiecesComponent> createState() =>
      _CapturedPiecesComponentState();
}

class _CapturedPiecesComponentState extends State<CapturedPiecesComponent> {
  String pieceStyle = "";

  /// Initializes state and loads saved piece style from SharedPreferences.
  @override
  void initState() {
    super.initState();
    _loadPieceStyle();
  }

  /// Loads the piece style from SharedPreferences.
  ///
  /// @return Future that completes when the style is loaded
  Future<void> _loadPieceStyle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    pieceStyle = prefs.getString('piece_style') ?? 'alpha';
  }

  /// Builds the row of captured piece images sorted by piece value.
  ///
  /// @return Widget containing the captured pieces row
  Widget _capturedPieces() {
    widget.capturedPieces.sort(
      (a, b) => pieceValue(a.type).compareTo(pieceValue(b.type)),
    );
    List<Widget> images = widget.capturedPieces.map((piece) {
      return SvgPicture.asset(
        'assets/images/${pieceTypeToSVG(piece.type, piece.color, pieceStyle)}',
        width: 30,
        height: 30,
      );
    }).toList();
    return Container(
      height: 30,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: images,
      ),
    );
  }

  /// Returns the captured pieces widget.
  ///
  /// @param context build context
  /// @return Widget built by _capturedPieces
  @override
  Widget build(BuildContext context) {
    return _capturedPieces();
  }
}
