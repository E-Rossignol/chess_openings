import 'package:flutter/material.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';

class AnalysisBar extends StatelessWidget {
  double value; // Valeur entre -10 et 10
  final double size;

  AnalysisBar({super.key, required this.value, required this.size});

  @override
  Widget build(BuildContext context) {
    if (value > 10){
      value = 10;
    }
    if (value < -10){
      value = -10;
    }
    value += 10;
    double percentage = value / 20;
    return Center(
      child: LinearPercentIndicator(
        width: size,
        curve: Curves.linear,
        lineHeight: 20.0,
        percent: percentage,
        backgroundColor: Colors.grey[300],
        progressColor: percentage > 0 ? Colors.black : Colors.red,
      ),
    );
  }
}