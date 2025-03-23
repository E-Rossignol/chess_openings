import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants.dart';
import '../model/board.dart';
import '../views/bot_view.dart';

class BotSettingsDialogComponent extends StatefulWidget {
  const BotSettingsDialogComponent({super.key});

  @override
  State<BotSettingsDialogComponent> createState() => _BotSettingsDialogComponentState();
}

class _BotSettingsDialogComponentState extends State<BotSettingsDialogComponent> {
  int difficulty = 4;
  bool isBotWhite = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bot settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Choose difficulty)'),
          Slider(
            value: difficulty.toDouble(),
            min: 1,
            max: 8,
            divisions: 7,
            label: difficulty.toString(),
            onChanged: (double newValue) {
              setState(() {
                difficulty = newValue.toInt();
              });
            },
          ),
          const SizedBox(height: 20),
          const Text('Bot color'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isBotWhite = true;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isBotWhite ? Colors.grey : Colors.transparent,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/${pieceTypeToSVG(PieceType.king, PieceColor.white, 'classic')}',
                      width: isBotWhite ? 70:50,
                      height: isBotWhite ? 70:50,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isBotWhite = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: !isBotWhite ? Colors.grey : Colors.transparent,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/${pieceTypeToSVG(PieceType.king, PieceColor.black, 'classic')}',
                      width: !isBotWhite ? 70: 50,
                      height: !isBotWhite ? 70: 50,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => BotView(board: Board(), difficulty: difficulty, isBotWhite: isBotWhite)));
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
