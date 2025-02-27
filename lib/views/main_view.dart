import 'package:chess_ouvertures/constants.dart';
import 'package:chess_ouvertures/database/database_helper.dart';
import 'package:chess_ouvertures/views/board_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../model/board.dart';
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
                            offset: Offset(0, 3),
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
                          child: const Text("Play game",
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
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Choose bot color:'),
                                  content: SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title: SvgPicture.asset(
                                              'assets/images/${pieceTypeToSVG(PieceType.king, PieceColor.white)}',
                                              width: 60,
                                              height: 60,
                                            ),
                                            onTap: () {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          BoardView(
                                                              board: Board(),
                                                              hasBot: true,
                                                              botColor:
                                                                  PieceColor
                                                                      .white)));
                                            },
                                          ),
                                          ListTile(
                                            title: SvgPicture.asset(
                                                'assets/images/${pieceTypeToSVG(PieceType.king, PieceColor.black)}',
                                                width: 60,
                                                height: 60),
                                            onTap: () {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          BoardView(
                                                              board: Board(),
                                                              hasBot: true,
                                                              botColor:
                                                                  PieceColor
                                                                      .black)));
                                            },
                                          ),
                                        ]),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text("Play against stupid bot",
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
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OpeningView()));
                          },
                          child: const Text("Go to your openings",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)))),
                  Row(
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
                                offset: Offset(0, 3),
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
                              child: const Text("Inspect Tables",
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
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child:  TextButton(
                            onPressed: () async {
                              bool result = await DatabaseHelper().resetTables();
                              if (result){
                                print("Tables deleted succesfully");
                              }
                            },
                            child: const Text("Reset Tables",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20))),
                      ),
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
