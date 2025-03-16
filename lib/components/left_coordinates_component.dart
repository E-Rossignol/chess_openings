import 'package:flutter/material.dart';

class LeftCoordinatesComponent extends StatefulWidget {
  const LeftCoordinatesComponent({super.key});

  @override
  State<LeftCoordinatesComponent> createState() => _LeftCoordinatesComponentState();
}

class _LeftCoordinatesComponentState extends State<LeftCoordinatesComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(8, (index) {
        return Container(
          padding: const EdgeInsets.only(left: 5, bottom: 25, right: 5),
          child: Text(
            '${8 - index}',
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
