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
          height: (MediaQuery.of(context).size.width - 25) / 8,
          padding: const EdgeInsets.only(bottom: 25, right: 10),
          alignment: Alignment.center,
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
