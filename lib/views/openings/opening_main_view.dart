import 'package:chess_ouvertures/database/database_helper.dart';
import 'package:chess_ouvertures/model/openings/opening.dart';
import 'package:chess_ouvertures/views/main_view.dart';
import 'package:chess_ouvertures/views/openings/new_opening_view.dart';
import 'package:chess_ouvertures/views/openings/opening_board_view.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../model/board.dart';

class OpeningView extends StatefulWidget {
  const OpeningView({super.key});

  @override
  State<OpeningView> createState() => _OpeningViewState();
}

class _OpeningViewState extends State<OpeningView> {
  Future<List<String>>? openingsName;
  String? selectedOpening;
  String selectedDefaultOpening = "Italian";
  List<String> defaultOpeningsList = [
    "Italian",
    "Queen's Gambit",
    "French Defense",
    "Sicilian Defense",
  ];

  Future<void> _loadOpenings() async {
    openingsName = DatabaseHelper().getOpeningsNames();
  }

  Future<Opening?> _loadDefaultOpening(String openingName) async {
    DatabaseHelper db = DatabaseHelper();
    switch (openingName) {
      case "Italian":
        await db.insertItalianOpening();
        break;
      case "Queen's Gambit":
        await db.insertQueensGambitOpening();
        break;
      case "French Defense":
        await db.insertFrenchDefenseOpening();
        break;
      case "Sicilian Defense":
        await db.insertSicilianDefenseOpening();
        break;
    }
    Opening? op = await db.getOpeningByName(openingName);
    return op;
  }

  void _openDefaultOpeningsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Openings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose opening'),
                DropdownButton<String>(
                  value: selectedDefaultOpening,
                  items: defaultOpeningsList.map((String opening) {
                    return DropdownMenuItem<String>(
                      value: opening,
                      child: Text(opening),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDefaultOpening = newValue!;
                    });
                    Navigator.of(context).pop();
                    _openDefaultOpeningsDialog();
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Ferme la boîte de dialogue
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Opening? op =
                      await _loadDefaultOpening(selectedDefaultOpening);
                  if (op != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OpeningBoardView(
                          board: Board(),
                          opening: op,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error'),
                      ),
                    );
                  }
                },
                child: const Text('Ok'),
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _loadOpenings();
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration iconButtonDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.grey.shade200, Colors.grey.shade700],
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
    );
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
        Column(
          children: [
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_sharp,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainView()),
                  );
                },
              ),
            ),
          ],
        ),
        Opacity(
          opacity: 1,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: iconButtonDecoration,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NewOpeningView(
                                              openingId: null,
                                              name: null,
                                              isWhite: null,
                                              isEdit: false)),
                                );
                              },
                              child: const Text("New opening",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black,
                                  )),
                            ),
                          ),
                        ]),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                ),
                Container(
                  decoration: iconButtonDecoration,
                  child: IntrinsicWidth(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 180,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  selectedOpening = null;
                                });
                              },
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.black,
                              )),
                          FutureBuilder<List<String>>(
                            future: openingsName,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text(
                                  'No opening yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              } else {
                                return DropdownButton<String>(
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black,
                                  ),
                                  value: selectedOpening,
                                  hint: Text(
                                    "Select opening",
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),
                                  items: snapshot.data!.map((String opening) {
                                    return DropdownMenuItem<String>(
                                      value: opening,
                                      child: Text(
                                        opening,
                                        style: const TextStyle(
                                          fontSize: 19,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedOpening = newValue;
                                    });
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (selectedOpening != null)
                  SizedBox(
                    height: 30,
                    width: MediaQuery.of(context).size.width,
                  ),
                if (selectedOpening != null)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: iconButtonDecoration,
                            child: IconButton(
                              onPressed: () async {
                                Opening? opening = await DatabaseHelper()
                                    .getOpeningByName(selectedOpening!);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OpeningBoardView(
                                        board: Board(),
                                        opening: opening!,
                                      ),
                                    ));
                              },
                              icon: const Icon(
                                Icons.play_circle,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            decoration: iconButtonDecoration,
                            child: IconButton(
                              onPressed: () async {
                                Opening? opening = await DatabaseHelper()
                                    .getOpeningByName(selectedOpening!);
                                int? id = await DatabaseHelper()
                                    .getOpeningIdByName(selectedOpening!);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewOpeningView(
                                        openingId: id!,
                                        isEdit: true,
                                        name: opening!.name,
                                        isWhite:
                                            opening.color == PieceColor.white,
                                      ),
                                    ));
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            decoration: iconButtonDecoration,
                            child: IconButton(
                              onPressed: () {
                                _showDeleteDialog(context);
                              },
                              icon: const Icon(
                                Icons.delete_outlined,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Center(
                    child: Container(
                      decoration: iconButtonDecoration,
                      child: IconButton(
                        onPressed: () {
                          _openDefaultOpeningsDialog();
                        },
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Delete "$selectedOpening" ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedOpening != null) {
                  await DatabaseHelper().deleteOpening(selectedOpening!);
                  setState(() {
                    selectedOpening = null;
                    _loadOpenings();
                  });
                  Navigator.of(context).pop(); // Ferme la boîte de dialogue
                }
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
