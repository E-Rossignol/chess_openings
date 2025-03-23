import 'package:flutter/material.dart';

class ChessBoardPreview extends StatelessWidget {
  final Color selectedColor;

  const ChessBoardPreview({required this.selectedColor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemBuilder: (context, index) {
          final bool isWhite = (index ~/ 8 % 2 == 0) ? index % 2 == 0 : index % 2 != 0;
          return Container(
            color: isWhite ? selectedColor.withOpacity(0.7) : selectedColor.withOpacity(0.3),
          );
        },
        itemCount: 16,
      ),
    );
  }
}