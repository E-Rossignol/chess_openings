import 'package:flutter/material.dart';

class BottomCoordinatesComponent extends StatefulWidget {
  final bool isReversed;
  const BottomCoordinatesComponent({super.key, required this.isReversed});

  @override
  State<BottomCoordinatesComponent> createState() => _BottomCoordinatesComponentState();
}

class _BottomCoordinatesComponentState extends State<BottomCoordinatesComponent> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(8, (index) {
        return Container(
          width:
          (MediaQuery.of(context).size.width - 25) / 8,
          alignment: Alignment.center,
          child:
          Text(
            widget.isReversed ? String.fromCharCode(104 - index) :
            String.fromCharCode(65 + index),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.white,
            ),
          ),
        );
      }),
    );
  }
}
