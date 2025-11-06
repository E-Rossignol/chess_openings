// ignore_for_file: use_build_context_synchronously

import 'package:chess_openings/helpers/constants.dart';
import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'database_view.dart';

class DatabaseMainView extends StatefulWidget {
  const DatabaseMainView({super.key});

  @override
  State<DatabaseMainView> createState() => _DatabaseMainViewState();
}

class _DatabaseMainViewState extends State<DatabaseMainView> {

  void _showSecretDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Secret Code'),
          content: TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter code',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (codeController.text == '256333') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Welcome Erwan')),
                  );
                  await DatabaseHelper().database;
                  DatabaseHelper().insertErwanOpenings();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid code')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryThemeDarkColor,
              primaryThemeLightColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryThemeDarkColor, primaryThemeLightColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DatabaseView()));
                    },
                    child: const Text("Inspect",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)))),
            const SizedBox(
              height: 40,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryThemeDarkColor, primaryThemeLightColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextButton(
                  onPressed: () async {
                    bool result = await DatabaseHelper().resetTables();
                    if (result) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Tables reseted"),
                      ));
                    }
                  },
                  child: const Text("Reset",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20))),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryThemeDarkColor, primaryThemeLightColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextButton(
                  onPressed: () async {
                    _showSecretDialog(context);
                    },
                  child: const Text("???",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 20))),
            ),
          ],
        ),
      ),
    );
  }
}
