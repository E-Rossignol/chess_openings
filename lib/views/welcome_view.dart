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
    if (_codeController.text == "chess-izy") {
      // Redirige vers MainView si le code est correct
      prefs.setBool('hasCode', true);
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
      appBar: AppBar(
        title: const Text("Bienvenue"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Bienvenue dans Chess Izy !",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Veuillez entrer le code pour continuer :",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Code",
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validateCode,
              child: const Text("Valider"),
            ),
          ],
        ),
      ),
    );
  }
}