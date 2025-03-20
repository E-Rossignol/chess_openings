import 'package:chess_ouvertures/database/database_helper.dart';
import 'package:chess_ouvertures/model/openings/opening.dart';
import 'package:chess_ouvertures/views/main_view.dart';
import 'package:chess_ouvertures/views/openings/new_opening_view.dart';
import 'package:chess_ouvertures/views/openings/opening_board_view.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../model/board.dart';
import '../board_view.dart';

class OpeningMainView extends StatelessWidget {
  final Key key;

  const OpeningMainView({required this.key}): super(key: key);
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
    Navigator.push(
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

  Future<void> _navigateToOpeningBoardView(String openingName) async  {
    Opening? opening = await DatabaseHelper().getOpeningByName(openingName);
    if (opening != null){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OpeningBoardView(
            board: Board(),
            opening: opening,
          ),
        ),
      );
    }
    else {
      return;
    }
  }

  Future<void> _navigateToEditOpeningView(String selectedOpening) async{
    Opening? opening = await DatabaseHelper()
        .getOpeningByName(selectedOpening!);
    int? id = await DatabaseHelper()
        .getOpeningIdByName(selectedOpening!);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              NewOpeningView(
                openingId: id!,
                isEdit: true,
                name: opening!.name,
                isWhite: opening.color ==
                    PieceColor.white,
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(48, 46, 43, 1),
                Color.fromRGBO(38, 37, 34, 1)
              ],
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
                                    items: [
                                      ...nonDefaultOpenings
                                          .map((String opening) {
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
                                      const DropdownMenuItem<String>(
                                        enabled: false,
                                        child: Text(
                                          "Default:",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      ...defaultOpenings.map((String opening) {
                                        return DropdownMenuItem<String>(
                                          value: opening,
                                          child: Text(
                                            opening,
                                            style: TextStyle(
                                              fontSize: 19,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (String? newValue) async{
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
                                    await _navigateToOpeningBoardView(selectedOpening!);
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
                                      await _navigateToEditOpeningView(selectedOpening!);
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
