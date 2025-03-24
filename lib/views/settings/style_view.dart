import 'package:chess_ouvertures/model/style_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/constants.dart';

class StyleView extends StatefulWidget {
  const StyleView({super.key});

  @override
  State<StyleView> createState() => _StyleViewState();
}

class BoardColorPicker extends StatelessWidget {
  final Color color1;
  final Color color2;

  const BoardColorPicker(
      {required this.color1, required this.color2, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Column(
        children: [
          Row(
            children: [
              _buildSquare(color1),
              _buildSquare(color2),
              _buildSquare(color1),
              _buildSquare(color2),
            ],
          ),
          Row(
            children: [
              _buildSquare(color2),
              _buildSquare(color1),
              _buildSquare(color2),
              _buildSquare(color1),
            ],
          ),
          Row(
            children: [
              _buildSquare(color1),
              _buildSquare(color2),
              _buildSquare(color1),
              _buildSquare(color2),
            ],
          ),
          Row(
            children: [
              _buildSquare(color2),
              _buildSquare(color1),
              _buildSquare(color2),
              _buildSquare(color1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSquare(Color color) {
    return Container(
      width: 35,
      height: 35,
      color: color,
    );
  }
}

class PieceStylePicker extends StatelessWidget {
  final List<SvgPicture> pieces;
  final bool isSelected;

  const PieceStylePicker(
      {required this.pieces, super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    String txt = "";
    if (pieces.first.pictureProvider.toString().contains('alpha')) {
      txt = 'Alpha';
    } else if (pieces.first.pictureProvider.toString().contains('classic')) {
      txt = 'Classic';
    } else if (pieces.first.pictureProvider.toString().contains('cardinal')) {
      txt = 'Cardinal';
    } else if (pieces.first.pictureProvider.toString().contains('chessnut')) {
      txt = 'Chessnut';
    } else if (pieces.first.pictureProvider.toString().contains('spatial')) {
      txt = 'Spatial';
    } else if (pieces.first.pictureProvider.toString().contains('tatiana')) {
      txt = 'Tatiana';
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  txt,
                  style: TextStyle(
                      color: isSelected
                          ? const Color.fromRGBO(183, 0, 0, 1)
                          : Colors.white,
                      fontSize: isSelected ? 25 : 20,
                      fontStyle:
                          isSelected ? FontStyle.italic : FontStyle.normal),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _buildPiece([pieces[0], pieces[1], pieces[2]]),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _buildPiece([pieces[3], pieces[4], pieces[5]]),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPiece(List<SvgPicture> pieces) {
    List<Widget> res = [];
    for (SvgPicture piece in pieces) {
      res.add(Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: secondaryThemeDarkColor,
            width: 2,
          ),
          color: secondaryThemeLightColor,
        ),
        child: piece,
      ));
    }
    return res;
  }
}

class _StyleViewState extends State<StyleView> {
  Color selectedColor = Colors.primaries.first;
  int selectedStyle = 0;
  StylePreferences stylePreferences = StylePreferences();
  @override
  initState() {
    super.initState();
    _getColor();
    _getPieceStyle();
  }

  Future<void> _getColor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String colorStr = prefs.getString('selected_color') ?? 'green';
    setState(() {
      selectedColor = getColor(colorStr)[0];
    });
  }

  Future<void> _getPieceStyle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String style = prefs.getString('piece_style') ?? 'classic';
    int res = 0;
    switch (style) {
      case 'classic':
        {
          res = 0;
          break;
        }
      case 'alpha':
        {
          res = 1;
          break;
        }
      case 'cardinal':
        {
          res = 2;
          break;
        }
      case 'chessnut':
        {
          res = 3;
          break;
        }
      case 'spatial':
        {
          res = 4;
          break;
        }
      case 'tatiana':
        {
          res = 5;
          break;
        }
      default:
        res = 0;
        break;
    }
    setState(() {
      selectedStyle = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<List<Color>> colors = boardColors;
    List<List<SvgPicture>> pieces = displayPieces;
    return Scaffold(
      backgroundColor: primaryThemeDarkColor,
      body: Center(
        child: DefaultTabController(
          length: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryThemeDarkColor, secondaryThemeLightColor],
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.9,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              children: [
                const TabBar(
                  isScrollable: false,
                  tabs: [
                    Tab(
                      child: Text(
                        'Board color',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Pieces style',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: colors.map((List<Color> colorPair) {
                              return GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    selectedColor = colorPair[0];
                                  });
                                  stylePreferences
                                      .updateColor(colorToStr(colorPair[0]));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: selectedColor == colorPair[0]
                                          ? const Color.fromRGBO(183, 0, 0, 1)
                                          : Colors.black,
                                      width: 4,
                                    ),
                                  ),
                                  margin: const EdgeInsets.all(10.0),
                                  child: BoardColorPicker(
                                    color1: colorPair[0],
                                    color2: colorPair[1],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: pieces.map((List<SvgPicture> style) {
                              int index = pieces.indexOf(style);
                              return GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    selectedStyle = index;
                                  });
                                  stylePreferences.updateStyle(selectedStyle);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: selectedStyle == index
                                          ? const Color.fromRGBO(183, 0, 0, 1)
                                          : Colors.transparent,
                                      width: 4,
                                    ),
                                  ),
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: PieceStylePicker(
                                      pieces: style,
                                      isSelected: selectedStyle == index),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Changes applied'),
            ),
          );
        },
        child: const Icon(Icons.done),
      ),
    );
  }
}
