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
  ValueNotifier<String> selectedStyle = ValueNotifier('classic');

  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedColor.value =
        _getColor(prefs.getString('selected_color') ?? 'green');
    selectedStyle.value = prefs.getString('piece_style') ?? 'classic';
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
    switch (index) {
      case 0:
        {
          prefs.setString('piece_style', 'classic');
          break;
        }
      case 1:
        {
          prefs.setString('piece_style', 'alpha');
          break;
        }
      case 2:
        {
          prefs.setString('piece_style', 'cardinal');
          break;
        }
      case 3:
        {
          prefs.setString('piece_style', 'chessnut');
          break;
        }
      case 4:
        {
          prefs.setString('piece_style', 'spatial');
          break;
        }
      case 5:
        {
          prefs.setString('piece_style', 'tatiana');
          break;
        }
      default:
        prefs.setString('piece_style', 'classic');
        break;
    }
    selectedStyle.value = prefs.getString('piece_style') ?? 'classic';
    notifyListeners();
  }

  List<Color> _getColor(String colorStr) {
    return getColor(colorStr);
  }
}
