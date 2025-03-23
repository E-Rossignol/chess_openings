// ignore_for_file: use_build_context_synchronously

import 'package:chess_ouvertures/constants.dart';
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../model/openings/opening.dart';
import 'database_view.dart';
import 'inspect_opening.dart';

class DatabaseMainView extends StatefulWidget {
  const DatabaseMainView({super.key});

  @override
  State<DatabaseMainView> createState() => _DatabaseMainViewState();
}

class _DatabaseMainViewState extends State<DatabaseMainView> {

  void _inspectOpeningDialog() async {
    List<String> openingNames = await DatabaseHelper().getOpeningsNames();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Choose opening"),
            content: SizedBox(
              height: 200,
              width: 200,
              child: ListView.builder(
                itemCount: openingNames.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(openingNames[index]),
                    onTap: () async {
                      Opening? opening = await DatabaseHelper().getOpeningByName(openingNames[index]);
                      if (opening != null){
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    InspectOpeningView(opening: opening)));
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Opening not found"),
                            )
                        );
                      }
                    },
                  );
                },
              ),
            ),
          );
        }
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
                    colors: [Colors.grey.shade400, Colors.grey.shade800],
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
                              builder: (context) =>
                              const DatabaseView()));
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
                  colors: [Colors.grey.shade400, Colors.grey.shade800],
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
              child:  TextButton(
                  onPressed: () async {
                    bool result = await DatabaseHelper().resetTables();
                    if (result){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Tables reseted"),
                          )
                      );
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
                  colors: [Colors.grey.shade400, Colors.grey.shade800],
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
              child:  TextButton(
                  onPressed: () {
                    _inspectOpeningDialog();
                  },
                  child: const Text("Inspect Opening",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20))),
            ),
          ],
        ),
      ),
    );
  }
}
