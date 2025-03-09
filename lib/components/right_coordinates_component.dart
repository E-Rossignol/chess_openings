import 'package:flutter/material.dart';

class RightCoordinatesComponent extends StatefulWidget {
  const RightCoordinatesComponent({super.key});

  @override
  State<RightCoordinatesComponent> createState() => _RightCoordinatesComponentState();
}

class _RightCoordinatesComponentState extends State<RightCoordinatesComponent> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(8, (index) {
        return Container(
          width:
          (MediaQuery.of(context).size.width - 25) / 8,
          alignment: Alignment.center,
          child: Text(
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
