// ignore_for_file: overridden_fields, use_build_context_synchronously

import 'package:chess_ouvertures/database/database_helper.dart';
import 'package:chess_ouvertures/model/openings/opening.dart';
import 'package:chess_ouvertures/views/openings/new_opening_view.dart';
import 'package:chess_ouvertures/views/openings/opening_board_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../helpers/constants.dart';
import '../model/board.dart';
import 'package:flutter/services.dart';

class OpeningMainView extends StatelessWidget {
  @override
  final Key key;

  const OpeningMainView({required this.key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => const OpeningView(),
        );
      },
    );
  }
}

class OpeningView extends StatefulWidget {
  const OpeningView({super.key});

  @override
  State<OpeningView> createState() => _OpeningViewState();
}

class _OpeningViewState extends State<OpeningView> {
  Future<List<String>> openingsName = DatabaseHelper().getOpeningsNames();
  String? selectedOpening;

  void _navigateToNewOpeningView() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const NewOpeningView(
          openingId: null,
          name: null,
          isWhite: null,
          isEdit: false,
        ),
      ),
    );
  }

  Future<void> _navigateToOpeningBoardView(String openingName) async {
    Opening? opening = await DatabaseHelper().getOpeningByName(openingName);
    if (opening != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OpeningBoardView(
            board: Board(),
            opening: opening,
          ),
        ),
      );
    } else {
      return;
    }
  }

  Future<void> _navigateToEditOpeningView(String selectedOpening) async {
    Opening? opening = await DatabaseHelper().getOpeningByName(selectedOpening);
    int? id = await DatabaseHelper().getOpeningIdByName(selectedOpening);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewOpeningView(
            openingId: id!,
            isEdit: true,
            name: opening!.name,
            isWhite: opening.color == PieceColor.white,
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> defaultOp = defaultOpenings();
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryThemeDarkColor, primaryThemeLightColor],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _navigateToNewOpeningView();
                                },
                                child: const Text("New opening",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black,
                                    )),
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
                            minHeight: 50,
                          ),
                          child: Center(
                            child: FutureBuilder<List<String>>(
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
                                    "No openings",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  );
                                } else {
                                  List<String> nonDefaultOpenings = snapshot
                                      .data!
                                      .where((opening) =>
                                          !defaultOp.contains(opening))
                                      .toList();
                                  List<String> defaultOpenings = snapshot.data!
                                      .where((opening) =>
                                          defaultOp.contains(opening))
                                      .toList();
                                  return DropdownButton<String>(
                                    borderRadius: BorderRadius.circular(12.0),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black,
                                    ),
                                    alignment: Alignment.center,
                                    value: selectedOpening,
                                    hint: Text(
                                      "Select opening",
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                    ),
                                    dropdownColor: primaryThemeLightColor,
                                    items: [
                                      ...nonDefaultOpenings
                                          .map((String opening) {
                                        return DropdownMenuItem<String>(
                                          value: opening,
                                          child: FutureBuilder<Opening?>(
                                            future: DatabaseHelper()
                                                .getOpeningByName(opening),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              } else if (snapshot.hasError ||
                                                  !snapshot.hasData) {
                                                return Text(opening);
                                              } else {
                                                Opening? op = snapshot.data;
                                                Color txtColor = op!.color ==
                                                        PieceColor.white
                                                    ? Colors.white
                                                    : Colors.black;
                                                return Center(
                                                  child: Text(
                                                    opening,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 19,
                                                      color: txtColor,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      }),
                                      const DropdownMenuItem<String>(
                                        enabled: false,
                                        child: Center(
                                          child: Text(
                                            "Default:",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      ...defaultOpenings.map((String opening) {
                                        return DropdownMenuItem<String>(
                                          value: opening,
                                          child: FutureBuilder<Opening?>(
                                            future: DatabaseHelper()
                                                .getOpeningByName(opening),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              } else if (snapshot.hasError ||
                                                  !snapshot.hasData) {
                                                return Text(opening);
                                              } else {
                                                Opening? op = snapshot.data;
                                                bool isWhite = op!.color ==
                                                    PieceColor.white;
                                                return Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      isWhite
                                                          ? SvgPicture.asset(
                                                              'assets/images/pieces/classic/wK.svg',
                                                              height: 30,
                                                              width: 30)
                                                          : SvgPicture.asset(
                                                              'assets/images/pieces/classic/bK.svg',
                                                              height: 30,
                                                              width: 30),
                                                      Text(
                                                        opening,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 19,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (String? newValue) async {
                                      setState(() {
                                        selectedOpening = newValue;
                                      });
                                    },
                                  );
                                }
                              },
                            ),
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
                                    await _navigateToOpeningBoardView(
                                        selectedOpening!);
                                  },
                                  icon: const Icon(
                                    Icons.play_circle,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              if (!defaultOp.contains(selectedOpening))
                                Container(
                                  decoration: iconButtonDecoration,
                                  child: IconButton(
                                    onPressed: () async {
                                      await _navigateToEditOpeningView(
                                          selectedOpening!);
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              if (!defaultOp.contains(selectedOpening))
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
                              Container(
                                decoration: iconButtonDecoration,
                                child: IconButton(
                                  onPressed: () {
                                    _showListStrDialog(
                                        context, selectedOpening!);
                                  },
                                  icon: const Icon(
                                    Icons.list,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedOpening != null) {
                  await DatabaseHelper().deleteOpening(selectedOpening!);
                  setState(() {
                    selectedOpening = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ouverture supprimée'),
                    ),
                  );
                  setState(() {
                    openingsName = DatabaseHelper().getOpeningsNames();
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

  Future<void> _showListStrDialog(
      BuildContext context, String selectedOpening) async {
    Opening? op = await DatabaseHelper().getOpeningByName(selectedOpening);
    List<String> moves = op!.toStr();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Liste des lignes'),
          content: Column(
            children: [
              for (int i = 0; i < moves.length; i++) Text(moves[i]),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    String str = "";
                    for (int i = 0; i < moves.length; i++) {
                      str += "${moves[i]} \n";
                    }
                    Clipboard.setData(ClipboardData(text: str));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copié dans le presse-papiers'),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Paste'),
                ),
                ElevatedButton(
                  onPressed: () {
                    String tmp = op.name.toLowerCase();
                    for (int i = 0; i < tmp.length; i++) {
                      if (tmp[i] == ' ') {
                        tmp = tmp.substring(0, i) +
                            tmp[i + 1].toUpperCase() +
                            tmp.substring(i + 2);
                      }
                      if (tmp[i] == '\'') {
                        tmp = tmp.substring(0, i) + tmp.substring(i + 1);
                      }
                    }
                    String str =
                        'List<String>${tmp}Opening(){ List<String> result = [];';
                    for (int i = 0; i < moves.length; i++) {
                      str += 'result.add("${moves[i]}");';
                    }
                    str += 'return result;}';
                    Clipboard.setData(ClipboardData(text: str));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('List<String> copiée dans le presse-papiers'),
                      ),
                    );
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('List<String> générée'),
                          content: Text(str),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Generate List'),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
