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
      child: Stack(
        children: [
          LinearPercentIndicator(
            width: size,
            curve: Curves.linear,
            lineHeight: 20.0,
            percent: percentage,
            backgroundColor: Colors.black,
            progressColor: Colors.white,
          ),
          Positioned(
            left: percentage > 0.5 ? 100 : null,
            right: percentage <= 0.5 ? 100 : null,
            child: Text(
              (value - 10).toStringAsFixed(1), // Affiche la valeur originale
              style: TextStyle(
                color: percentage > 0.5 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}