import 'package:chess_ouvertures/constants.dart';
import 'package:chess_ouvertures/model/openings/opening.dart';
import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../model/board.dart';
import '../main_view.dart';
import 'opening_board_view.dart';

class NewOpeningView extends StatefulWidget {
  const NewOpeningView({super.key});

  @override
  State<NewOpeningView> createState() => _NewOpeningViewState();
}

class _NewOpeningViewState extends State<NewOpeningView> {
  final _formKey = GlobalKey<FormState>();
  String _openingName = '';
  String _pieceColor = '';

  @override
  Widget build(BuildContext context) {
    TextStyle txtStyle = const TextStyle(
      fontSize: 20,
      color: Colors.white,
    );
    BoxDecoration decoration = BoxDecoration(
      color: Colors.white12,
      borderRadius: BorderRadius.circular(8.0),
    );
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      SizedBox(height: 50),
      Opacity(
        opacity: 1,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(children: [
            Column(
              children: [
                SizedBox(
                    height: 50
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white,),
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
            Form(
              key: _formKey,
              child: Center(
                heightFactor: 2,
                child: Container(
                  width: MediaQuery.of(context).size.width - 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 38.0),
                        decoration: decoration,
                        child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Opening Name',
                              labelStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.white38,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the opening name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _openingName = value!;
                            },
                            style: txtStyle),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        decoration: decoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Choose your POV color:',
                              style: txtStyle,
                            ),
                            ListTile(
                              title: Text(
                                'White',
                                style: txtStyle,
                              ),
                              leading: Radio<String>(
                                value: 'white',
                                groupValue: _pieceColor,
                                onChanged: (value) {
                                  setState(() {
                                    _pieceColor = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('Black', style: txtStyle),
                              leading: Radio<String>(
                                value: 'black',
                                groupValue: _pieceColor,
                                onChanged: (value) {
                                  setState(() {
                                    _pieceColor = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              bool result = await DatabaseHelper().insertOpening(_openingName, _pieceColor);
                              if (result) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ouverture créée avec succès')),
                                );
                                Opening opening = Opening(name: _openingName, color: _pieceColor == 'white' ? PieceColor.white : PieceColor.black, moves: []);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => OpeningBoardView(board: Board(),opening: opening)),
                                );
                              }
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}
