import 'package:chess_openings/database/database_helper.dart';
import 'package:chess_openings/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'main_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  final TextEditingController _codeController = TextEditingController();


  void _validateCode() async {
    var prefs = await SharedPreferences.getInstance();
    bool isOk = await DatabaseHelper().checkCode(_codeController.text);
    if (isOk) {
      // Redirige vers MainView si le code est correct
      prefs.setString('pw', _codeController.text);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainView(key: UniqueKey())),
      );
    } else {
      // Affiche une SnackBar si le code est incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Code incorrect. Veuillez réessayer."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryThemeDarkColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '"Chess is easy"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryThemeLightColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Veuillez entrer le code pour continuer :",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: primaryThemeLightColor),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: "Password",
                  labelStyle: TextStyle(color: primaryThemeLightColor),
                  hoverColor: primaryThemeLightColor,
                  focusColor: primaryThemeLightColor,
                ),
                style: TextStyle(color: primaryThemeLightColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryThemeLightColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _validateCode,
                child: Text("Valider", style: TextStyle(fontSize: 16, color: primaryThemeDarkColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}