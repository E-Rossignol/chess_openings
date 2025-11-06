import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';

class StylePreferences extends ChangeNotifier {
  static final StylePreferences _instance = StylePreferences._internal();

  // Constructeur privé
  StylePreferences._internal();

  // Méthode pour obtenir l'instance unique
  factory StylePreferences() {
    return _instance;
  }

  ValueNotifier<List<Color>> selectedColor = ValueNotifier(getColor('green'));
  ValueNotifier<String> selectedStyle = ValueNotifier('alpha');

  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedColor.value =
        _getColor(prefs.getString('selected_color') ?? 'green');
    selectedStyle.value = prefs.getString('piece_style') ?? 'alpha';
    notifyListeners();
  }

  Future<void> updateColor(String color) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selected_color', color);
    selectedColor.value = _getColor(color);
    notifyListeners();
  }
  Future<void> updateStyle(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('piece_style', styleNames[index]);
    selectedStyle.value = prefs.getString('piece_style') ?? 'alpha';
    notifyListeners();
  }

  List<Color> _getColor(String colorStr) {
    return getColor(colorStr);
  }
}
