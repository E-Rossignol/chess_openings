import 'package:flutter/material.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';

/// Widget that displays a horizontal analysis bar representing a value
/// between -10 and 10. The bar visualizes the value as a percentage and
/// shows the numeric value over the bar.
///
/// @param value numerical evaluation between -10 and 10 (will be clamped)
/// @param size width of the bar in pixels
class AnalysisBar extends StatelessWidget {
  double value;
  final double size;

  /// Creates an AnalysisBar.
  ///
  /// @param value evaluation between -10 and 10 (clamped internally)
  /// @param size width of the indicator
  AnalysisBar({super.key, required this.value, required this.size});

  /// Builds the visual representation of the analysis bar.
  ///
  /// @param context build context
  /// @return a centered Widget containing the percent indicator and value label
  @override
  Widget build(BuildContext context) {
    if (value > 10) {
      value = 10;
    }
    if (value < -10) {
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
              (value - 10).toStringAsFixed(1),
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
