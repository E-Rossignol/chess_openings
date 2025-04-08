// ignore_for_file: must_be_immutable, library_private_types_in_public_api, use_build_context_synchronously

import 'package:chess_ouvertures/components/captured_pieces_component.dart';
import 'package:chess_ouvertures/helpers/constants.dart';
import 'package:chess_ouvertures/model/openings/opening.dart';
import 'package:chess_ouvertures/model/style_preferences.dart';
import 'package:chess_ouvertures/views/opening_main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../database/database_helper.dart';
import '../../model/board.dart';
import '../../model/openings/opening_move.dart';
import '../../model/piece.dart';
import '../../model/square.dart';
import '../../helpers/painter.dart';

class OpeningBoardView extends StatefulWidget {
  final Board board;
  final StylePreferences stylePreferences = StylePreferences();
  Opening opening;

  OpeningBoardView({super.key, required this.board, required this.opening});

  @override
  _OpeningBoardViewState createState() => _OpeningBoardViewState();
}

class _OpeningBoardViewState extends State<OpeningBoardView> {
  int lastMoveId = -1;
  int? lastMoveFromRow;
  int? lastMoveFromCol;
  int? lastMoveToRow;
  int? lastMoveToCol;
  List<Square> validMoves = [];
  bool isReversed = false;
  Square? selectedSquare;
  String moveCountMessage = '0';
  bool isRecording = false;
  List<List<Square>> newVariant = [];
  List<List<Square>> moveHistory = [];
  List<int> moveIdHistory = [-1];
  Color whiteColor = Colors.white;
  Color blackColor = Colors.black;
  Color arrowColor = Colors.deepPurple;
  Color lastMoveColor = Colors.orange;
  String pieceStyle = "";
  List<Color> colors = [];

  @override
  void initState() {
    super.initState();
    _loadColorsFromPrefs();
    isReversed = widget.opening.color == PieceColor.black;
    widget.board.boardNotifier.addListener(_updateBoard);
    widget.board.moveCount.addListener(_updateMoveCount);
    widget.stylePreferences.selectedColor.addListener(_updateColors);
    widget.stylePreferences.selectedStyle.addListener(_updateStyle);
  }

  @override
  void dispose() {
    widget.board.boardNotifier.removeListener(_updateBoard);
    widget.board.moveCount.removeListener(_updateMoveCount);
    widget.stylePreferences.selectedColor.removeListener(_updateColors);
    widget.stylePreferences.selectedStyle.removeListener(_updateStyle);
    super.dispose();
  }

  void _loadColorsFromPrefs() {
    widget.stylePreferences.loadPreferences();
    setState(() {
      colors = StylePreferences().selectedColor.value;
      whiteColor = colors[0];
      blackColor = colors[1];
      arrowColor = colors[3];
      lastMoveColor = colors[2];
    });
  }

  void _updateBoard() {
    setState(() {});
  }

  void _updateColors() {
    setState(
      () {
        colors = widget.stylePreferences.selectedColor.value;
        whiteColor = colors[0];
        blackColor = colors[1];
        arrowColor = colors[3];
        lastMoveColor = colors[2];
      },
    );
  }

  void _updateStyle() {
    setState(() {
      pieceStyle = widget.stylePreferences.selectedStyle.value;
    });
  }

  void _updateMoveCount() {
    setState(() {
      moveCountMessage = (widget.board.moveCount.value ~/ 2).toString();
    });
  }

  void _resetBoard() {
    setState(() {
      widget.board.reset();
      moveIdHistory = [-1];
      moveHistory = [];
      validMoves = [];
      lastMoveFromRow = null;
      lastMoveFromCol = null;
      lastMoveToRow = null;
      lastMoveToCol = null;
      selectedSquare = null;
      lastMoveId = -1;
      newVariant = [];
    });
  }

  void _reverseBoard() {
    setState(() {
      isReversed = !isReversed;
    });
  }

  String scoreStr(int score) {
    String res = "";
    if (score != 0) {
      if (score > 0) {
        res = '+${score.toString()}';
      } else {
        res = score.toString();
      }
    }
    return res;
  }

  Future<void> _reloadOpening() async {
    Opening? op = await DatabaseHelper().getOpeningByName(widget.opening.name);
    if (op != null) {
      widget.opening = op;
    }
    _resetBoard();
  }

  void moveInOpening(OpeningMove move) {
    newVariant.add([move.from, move.to]);
    moveHistory.add([move.from, move.to]);
    moveIdHistory.add(move.id);
    widget.board
        .movePiece(move.from.row, move.from.col, move.to.row, move.to.col);
    setState(() {
      lastMoveFromRow = move.from.row;
      lastMoveFromCol = move.from.col;
      lastMoveToRow = move.to.row;
      lastMoveToCol = move.to.col;
      lastMoveId = move.id;
    });
  }

  Future<void> _showValidateVariantDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Validate record'),
          content: const Text("Are you sure to want to validate record ?"),
          actions: [
            Column(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _reShowVariant();
                        },
                        child: const Text('Show'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () async {
                          List<OpeningMove>? result = await DatabaseHelper()
                              .insertVariant(newVariant, widget.opening.name);
                          String message = "";
                          if (result != null && result.isNotEmpty) {
                            message =
                                "Added ${result.length} moves successfully.";
                          } else if (result != null && result.isEmpty) {
                            message = "You added 0 new move to the ouverture.";
                          } else {
                            message = "Error trying to store the variant";
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(message),
                          ));
                          isRecording = false;
                          Navigator.of(context).pop();
                          await _reloadOpening();
                        },
                        child: const Text('Yes'),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isRecording = false;
                            isRecording = false;
                          });
                          Navigator.of(context)
                              .pop(); // Ferme la boîte de dialogue
                        },
                        child: const Text('No'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showDeleteVariantDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Variant'),
          content: const Text(
              "Are you sure to want to delete variant from the last played move ?"),
          actions: [
            Column(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await DatabaseHelper()
                              .deleteOpeningMoveAndDescendants(lastMoveId);
                          String message = "Variant deleted succesfully.";
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(message),
                          ));
                          Navigator.of(context).pop();
                          await _reloadOpening();
                        },
                        child: const Text('Yes'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Ferme la boîte de dialogue
                        },
                        child: const Text('No'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _reShowVariant() async {
    List<List<Square>> tmp = newVariant;
    _resetBoard();
    newVariant = tmp;
    await Future.delayed(const Duration(seconds: 1));
    for (int i = 0; i < newVariant.length; i++) {
      List<Square> move = newVariant[i];
      setState(() {
        widget.board
            .movePiece(move[0].row, move[0].col, move[1].row, move[1].col);
      });
      await Future.delayed(const Duration(seconds: 1));
    }
    _showValidateVariantDialog();
  }

  void _undoLastMove() {
    if (moveHistory.isNotEmpty) {
      if (moveIdHistory.length > 1) {
        moveIdHistory.removeLast();
        lastMoveId = moveIdHistory.last;
      }
      moveHistory.removeLast();
      newVariant.removeLast();
      widget.board.undoLastMove(moveHistory);
    }
    lastMoveFromRow = moveHistory.isNotEmpty ? moveHistory.last[0].row : null;
    lastMoveFromCol = moveHistory.isNotEmpty ? moveHistory.last[0].col : null;
    lastMoveToRow = moveHistory.isNotEmpty ? moveHistory.last[1].row : null;
    lastMoveToCol = moveHistory.isNotEmpty ? moveHistory.last[1].col : null;
    _updateBoard();
  }

  void _playNextUniqueMove() {
    List<OpeningMove> move = widget.opening.moves
        .where((move) =>
            move.moveNumber == widget.board.moveCount.value &&
            move.previousMoveId == lastMoveId)
        .toList();
    if (move.length != 1) {
      return;
    }
    moveInOpening(move.first);
  }

  @override
  Widget build(BuildContext context) {
    int currentMoveNumber = widget.board.moveCount.value;
    bool isNextMoveUnique = widget.opening.moves
            .where((move) =>
                move.moveNumber == currentMoveNumber &&
                move.previousMoveId == lastMoveId)
            .length ==
        1;
    Color tmpWhiteColor = whiteColor;
    Color tmpBlackColor = blackColor;
    Color tmpArrowColor = arrowColor;
    Color tmpLastMoveColor = lastMoveColor;
    if (isRecording) {
      if (isReversed){
        tmpBlackColor = const Color.fromRGBO(255, 216, 216, 1.0);
        tmpWhiteColor = const Color.fromRGBO(200, 0, 0, 1.0);
        tmpLastMoveColor = const Color.fromRGBO(255, 165, 0, 1.0);
      }
      else {
        tmpWhiteColor = const Color.fromRGBO(255, 216, 216, 1.0);
        tmpBlackColor = const Color.fromRGBO(200, 0, 0, 1.0);
        tmpLastMoveColor = const Color.fromRGBO(255, 165, 0, 1.0);
      }
    }
    List<Color> bgColor = !isReversed
        ? [primaryThemeDarkColor, primaryThemeLightColor]
        : [primaryThemeLightColor, primaryThemeDarkColor];
    Color textColor = tmpWhiteColor;
    int topScore = isReversed
        ? (widget.board.whiteScore - widget.board.blackScore)
        : (widget.board.blackScore - widget.board.whiteScore);
    int bottomScore = isReversed
        ? (widget.board.blackScore - widget.board.whiteScore)
        : (widget.board.whiteScore - widget.board.blackScore);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColor,
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OpeningView()),
                  );
                },
              ),
            ),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_double_arrow_left),
                        onPressed: currentMoveNumber > 0 ? _undoLastMove : null,
                        disabledColor: Colors.grey,
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _resetBoard,
                      ),
                      IconButton(
                        icon: const Icon(Icons.flip, color: Colors.white),
                        onPressed: _reverseBoard,
                      ),
                      IconButton(
                        icon: const Icon(Icons.keyboard_double_arrow_right),
                        onPressed:
                            isNextMoveUnique ? _playNextUniqueMove : null,
                        disabledColor: Colors.grey,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  Center(
                    child: Text(widget.opening.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic)),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CapturedPiecesComponent(
                            capturedPieces: widget
                                .board.capturedPieceNotifier.value
                                .where((element) =>
                                    element.color ==
                                    (isReversed
                                        ? PieceColor.black
                                        : PieceColor.white))
                                .toList(),
                          ),
                          topScore > 0
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  height: 30,
                                  width: 30,
                                  child: Center(
                                      child: Text(
                                    scoreStr(topScore),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: textColor,
                                    ),
                                  )))
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 15),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                              width: 4,
                              color: secondaryThemeDarkColor,
                            )),
                            height: MediaQuery.of(context).size.width - 25,
                            width: MediaQuery.of(context).size.width - 25,
                            child: Center(
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                removeBottom: true,
                                removeLeft: true,
                                removeRight: true,
                                child: Stack(children: [
                                  GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8,
                                    ),
                                    itemBuilder: (context, index) {
                                      Color lastMoveColor = tmpLastMoveColor;
                                      final int row = isReversed
                                          ? 7 - (index ~/ 8)
                                          : index ~/ 8;
                                      final int col = isReversed
                                          ? 7 - (index % 8)
                                          : index % 8;
                                      final Square square =
                                          widget.board.board[row][col];
                                      bool isGameOver =
                                          widget.board.gameResult.value != 0;
                                      bool isLastFromSquare =
                                          square.row == lastMoveFromRow &&
                                              square.col == lastMoveFromCol;
                                      bool isLastToSquare =
                                          square.row == lastMoveToRow &&
                                              square.col == lastMoveToCol;
                                      Color squareColor = square.isWhite
                                          ? tmpWhiteColor
                                          : tmpBlackColor;
                                      Color otherColor = !square.isWhite
                                          ? tmpWhiteColor
                                          : tmpBlackColor;
                                      squareColor =
                                          isLastFromSquare || isLastToSquare
                                              ? lastMoveColor
                                              : squareColor;
                                      return GestureDetector(
                                        onTap: () {
                                          if (isGameOver) return;
                                          setState(() {
                                            if (!isRecording) {
                                              if (selectedSquare == null &&
                                                  square.piece != null &&
                                                  square.piece!.color ==
                                                      widget
                                                          .board.currentTurn) {
                                                selectedSquare = square;
                                                validMoves = widget.board
                                                    .getValidMoves(
                                                        square.piece!);
                                              } else if (selectedSquare !=
                                                      null &&
                                                  validMoves.contains(square)) {
                                                OpeningMove? move =
                                                    isInCurrentOpening(
                                                        selectedSquare!,
                                                        Square(row, col));
                                                if (move != null) {
                                                  moveInOpening(move);
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(const SnackBar(
                                                          content: Text(
                                                              "Move not available in you opening")));
                                                }
                                                selectedSquare = null;
                                                validMoves = [];
                                              } else {
                                                selectedSquare = null;
                                                validMoves = [];
                                              }
                                            } else {
                                              if (selectedSquare == null &&
                                                  square.piece != null &&
                                                  square.piece!.color ==
                                                      widget
                                                          .board.currentTurn) {
                                                selectedSquare = square;
                                                validMoves = widget.board
                                                    .getValidMoves(
                                                        square.piece!);
                                              } else if (selectedSquare !=
                                                      null &&
                                                  validMoves.contains(square)) {
                                                newVariant.add(
                                                    [selectedSquare!, square]);
                                                moveHistory.add(
                                                    [selectedSquare!, square]);
                                                widget.board.movePiece(
                                                  selectedSquare!.row,
                                                  selectedSquare!.col,
                                                  row,
                                                  col,
                                                );
                                                setState(() {
                                                  lastMoveFromRow =
                                                      selectedSquare!.row;
                                                  lastMoveFromCol =
                                                      selectedSquare!.col;
                                                  lastMoveToRow = row;
                                                  lastMoveToCol = col;
                                                });
                                                selectedSquare = null;
                                                validMoves = [];
                                              } else {
                                                selectedSquare = null;
                                                validMoves = [];
                                              }
                                            }
                                          });
                                        },
                                        child: Stack(
                                          children: [
                                            isLastToSquare || isLastFromSquare
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.black
                                                              .withOpacity(0.5),
                                                          width: 1,
                                                        ),
                                                        color: squareColor),
                                                    child: _buildPiece(
                                                        square.piece),
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                        color: squareColor),
                                                    child: _buildPiece(
                                                        square.piece),
                                                  ),
                                            if (coordinatesIndexes
                                                .contains(index))
                                              Positioned(
                                                bottom: index > 56 ? 2 : null,
                                                right: index > 56 ? 2 : null,
                                                top: index <= 56 ? 2 : null,
                                                left: index <= 56 ? 2 : null,
                                                child: Text(
                                                  indexes(index, isReversed),
                                                  style: TextStyle(
                                                    color: otherColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            if (index == 56)
                                              Positioned(
                                                bottom: 2,
                                                right: 2,
                                                child: Text(
                                                  !isReversed ? "a" : "h",
                                                  style: TextStyle(
                                                    color: otherColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            if (square.piece != null &&
                                                square.piece!.type ==
                                                    PieceType.king &&
                                                widget.board.isCheck(
                                                    square.piece!.color) &&
                                                !!widget.board.isCheckmate())
                                              Positioned(
                                                top: 2,
                                                right: 2,
                                                child: Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: Colors.redAccent
                                                        .withOpacity(1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            if (validMoves.contains(square) &&
                                                square.piece == null &&
                                                isInCurrentOpening(
                                                        selectedSquare!,
                                                        square) !=
                                                    null &&
                                                !isRecording)
                                              Center(
                                                child: Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: tmpArrowColor
                                                        .withOpacity(0.8),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            if (validMoves.contains(square) &&
                                                square.piece == null &&
                                                isRecording)
                                              Center(
                                                child: Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color.fromRGBO(
                                                        108, 0, 0, 0.9),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            if (validMoves.contains(square) &&
                                                square.piece != null)
                                              Container(
                                                color: Colors.redAccent
                                                    .withOpacity(0.5),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                    itemCount: 64,
                                  ),
                                  IgnorePointer(
                                    child: Opacity(
                                      opacity: isRecording ? 0.0 : 1.0,
                                      child: CustomPaint(
                                        size: Size(
                                            MediaQuery.of(context).size.width -
                                                25,
                                            MediaQuery.of(context).size.width -
                                                25),
                                        painter: ArrowPainter(
                                            moves: widget.opening.moves
                                                .where((move) =>
                                                    move.moveNumber ==
                                                        currentMoveNumber &&
                                                    lastMoveId ==
                                                        move.previousMoveId)
                                                .toList(),
                                            isReversed: isReversed,
                                            color: arrowColor),
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CapturedPiecesComponent(
                            capturedPieces: widget
                                .board.capturedPieceNotifier.value
                                .where((element) =>
                                    element.color ==
                                    (isReversed
                                        ? PieceColor.white
                                        : PieceColor.black))
                                .toList(),
                          ),
                          bottomScore > 0
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  height: 30,
                                  width: 30,
                                  child: Center(
                                      child: Text(
                                    scoreStr(bottomScore),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: textColor,
                                    ),
                                  )))
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (!isRecording) {
                                      setState(() {
                                        isRecording = true;
                                      });
                                    } else if (newVariant.isNotEmpty) {
                                      await _showValidateVariantDialog();
                                    } else {
                                      setState(() {
                                        isRecording = false;
                                      });
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      color: isRecording
                                          ? Colors.red
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        isRecording
                                            ? Icons.stop
                                            : Icons.fiber_manual_record,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isRecording)
                                  IconButton(
                                      onPressed: _showDeleteVariantDialog,
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                      )),
                              ],
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Move n°$moveCountMessage',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ))
          ],
        ),
      ),
    );
  }

  OpeningMove? isInCurrentOpening(Square from, Square to) {
    List<OpeningMove>? doneMove = widget.opening.moves
        .where((element) =>
            element.from.row == from.row &&
            element.from.col == from.col &&
            element.to.row == to.row &&
            element.to.col == to.col &&
            element.moveNumber == widget.board.moveCount.value &&
            element.previousMoveId == lastMoveId)
        .toList();
    if (doneMove.isNotEmpty) {
      return doneMove.first;
    } else {
      return null;
    }
  }

  Widget _buildPiece(Piece? piece) {
    if (piece == null) {
      return Container();
    }
    return Stack(
      children: [
        Center(
          child: SvgPicture.asset(
            'assets/images/${pieceTypeToSVG(piece.type, piece.color, pieceStyle)}',
            width: 60,
            height: 60,
          ),
        ),
      ],
    );
  }
}
