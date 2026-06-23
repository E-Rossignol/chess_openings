import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';

/// Singleton change notifier managing piece style and board color preferences.
///
/// Exposes ValueNotifiers for UI binding and provides persistence via SharedPreferences.
class StylePreferences extends ChangeNotifier {
  static final StylePreferences _instance = StylePreferences._internal();

  /// Private constructor for singleton.
  StylePreferences._internal();

  /// Returns the singleton instance.
  factory StylePreferences() {
    return _instance;
  }

  ValueNotifier<List<Color>> selectedColor = ValueNotifier(getColor('green'));
  ValueNotifier<String> selectedStyle = ValueNotifier('alpha');

  /// Loads saved preferences from SharedPreferences into the notifiers.
  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedColor.value = _getColor(
      prefs.getString('selected_color') ?? 'green',
    );
    selectedStyle.value = prefs.getString('piece_style') ?? 'alpha';
    notifyListeners();
  }

  /// Updates the selected color and persists it.
  ///
  /// @param color string name of the color palette
  Future<void> updateColor(String color) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selected_color', color);
    selectedColor.value = _getColor(color);
    notifyListeners();
  }

  /// Updates the selected piece style by index and persists it.
  ///
  /// @param index index into styleNames list
  Future<void> updateStyle(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('piece_style', styleNames[index]);
    selectedStyle.value = prefs.getString('piece_style') ?? 'alpha';
    notifyListeners();
  }

  /// Internal helper returning a color list for a given string identifier.
  ///
  /// @param colorStr string key for palette
  /// @return List<Color> corresponding palette
  List<Color> _getColor(String colorStr) {
    return getColor(colorStr);
  }
}
