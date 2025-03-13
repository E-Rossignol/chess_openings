import 'package:chess_ouvertures/components/bot_settings_dialog_component.dart';
import 'package:chess_ouvertures/constants.dart';
import 'package:chess_ouvertures/database/database_helper.dart';
import 'package:chess_ouvertures/views/board_view.dart';
import 'package:chess_ouvertures/views/bot_view.dart';
import 'package:chess_ouvertures/views/openings/opening_board_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../model/board.dart';
import '../model/openings/opening.dart';
import 'database_view.dart';
import 'openings/opening_main_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  @override
  void initState() {
    super.initState();
    _initializeDatabase();

  }

  Future<void> _initializeDatabase() async {
    await DatabaseHelper().database;
  }

  void _showBotSettingsDialog() {
    int difficulty = 1;
    bool isBotWhite = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BotSettingsDialogComponent();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Opacity(
          opacity: 0.8,
          child: Center(
            child: SizedBox(
              height: 300,
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    builder: (context) => const OpeningView()));
                          },
                          child: const Text("Openings",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)))),
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
                            _showBotSettingsDialog();
                          },
                          child: const Text("Play game with bot",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)))),
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
                                        BoardView(board: Board())));
                          },
                          child: const Text("Play game alone",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
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
                      ),
                      const SizedBox(width: 40),
                      Expanded(
                        child: Container(
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
                          child: TextButton(
                              onPressed: () async {
                                await DatabaseHelper().insertDefaultOpenings();
                                Opening? opening = await DatabaseHelper().getOpeningByName("Italian");
                                if (opening != null){
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              OpeningBoardView(board: Board(), opening: opening)));
                                }
                                else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Error"),
                                    )
                                  );
                                }
                              },
                              child: const Text("Default Openings",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)))),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
