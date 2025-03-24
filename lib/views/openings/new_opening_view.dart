// ignore_for_file: use_build_context_synchronously

import 'package:chess_ouvertures/model/openings/opening.dart';
import 'package:chess_ouvertures/views/opening_main_view.dart';
import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../model/board.dart';
import 'opening_board_view.dart';
import '../../helpers/constants.dart';

class NewOpeningView extends StatefulWidget {
  final String? name;
  final bool? isWhite;
  final bool isEdit;
  final int? openingId;
  const NewOpeningView(
      {super.key,
      required this.name,
      required this.isWhite,
      required this.isEdit,
      required this.openingId});

  @override
  State<NewOpeningView> createState() => _NewOpeningViewState();
}

class _NewOpeningViewState extends State<NewOpeningView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String _pieceColor = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name ?? '');
    if (widget.isWhite != null) {
      _pieceColor = widget.isWhite! ? 'white' : 'black';
    }
  }

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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryThemeDarkColor, primaryThemeLightColor],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
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
                      MaterialPageRoute(
                          builder: (context) => const OpeningView()),
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
              child: SizedBox(
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
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Opening Name',
                            labelStyle: TextStyle(
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
                            bool result = false;
                            String message = "";
                            if (widget.openingId != null) {
                              result = await DatabaseHelper().editOpening(
                                  widget.openingId!,
                                  _nameController.value.text,
                                  _pieceColor);
                              message = "Ouverture edited";
                            } else {
                              result = await DatabaseHelper().insertOpening(
                                  _nameController.value.text,
                                  _pieceColor,
                                  false);
                              message = "Ouverture created";
                            }
                            if (result) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                              Opening? opening = await DatabaseHelper()
                                  .getOpeningByName(_nameController.value.text);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OpeningBoardView(
                                      board: Board(),
                                      opening: opening!,
                                    ),
                                  ));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Error inserting new opening.")));
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
    );
  }
}
