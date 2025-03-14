import 'package:chess_ouvertures/components/left_coordinates_component.dart';
import 'package:chess_ouvertures/components/bottom_coordinates_component.dart';
import 'package:chess_ouvertures/constants.dart';
import 'package:chess_ouvertures/model/openings/opening.dart';
import 'package:chess_ouvertures/views/openings/opening_main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../database/database_helper.dart';
import '../../model/board.dart';
import '../../model/openings/opening_move.dart';
import '../../model/piece.dart';
import '../../model/square.dart';
import '../../painter.dart';

class OpeningBoardView extends StatefulWidget {
  final Board board;
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
  String variantName = "";
  List<List<Square>> moveHistory = [];
  List<int> moveIdHistory = [-1];

  @override
  void initState() {
    super.initState();
    isReversed = widget.opening.color == PieceColor.black;
    widget.board.boardNotifier.addListener(_updateBoard);
    widget.board.moveCount.addListener(_updateMoveCount);
  }

  @override
  void dispose() {
    widget.board.boardNotifier.removeListener(_updateBoard);
    super.dispose();
  }

  void _updateBoard() {
    setState(() {});
  }

  void _updateMoveCount() {
    setState(() {
      moveCountMessage = widget.board.moveCount.value.toString();
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
      variantName = "";
    });
  }

  void _reverseBoard() {
    setState(() {
      isReversed = !isReversed;
    });
  }

  Future<void> _reloadOpening() async {
    _resetBoard();
    Opening? op = await DatabaseHelper().getOpeningByName(widget.opening.name);
    if (op != null){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => OpeningBoardView(board: widget.board, opening: op)),
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error")));
    }
  }

  void moveInOpening(OpeningMove move){
    newVariant.add(
        [move.from, move.to]);
    moveHistory.add(
        [move.from, move.to]);
    moveIdHistory.add(move.id);
    widget.board.movePiece(
        move.from.row,
        move.from.col,
        move.to.row,
        move.to.col);
    setState(() {
      lastMoveFromRow = move.from.row;
      lastMoveFromCol = move.from.col;
      lastMoveToRow = move.to.row;
      lastMoveToCol = move.to.col;
      lastMoveId = move.id;
    });
  }

  void _showValidateVariantDialog() {
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
                          List<OpeningMove>? result = await DatabaseHelper()
                              .insertVariant(
                              newVariant, widget.opening.name, variantName);
                          String message = "";
                          if (result != null && result.isNotEmpty) {
                            for (OpeningMove move in result) {
                              setState(() {
                                widget.opening.moves.add(move);
                              });
                            }
                            message = "Variant recorded successfully.";
                          } else if (result != null && result.isEmpty) {
                            message = "You added 0 new move to the ouverture.";
                          } else {
                            message = "Error trying to store the variant";
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(message),
                          ));
                          await _reloadOpening();
                        },
                        child: const Text('Yes'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isRecording = false;
                          });
                          Navigator.of(context)
                              .pop(); // Ferme la boîte de dialogue
                        },
                        child: const Text('No'),
                      ),
                    ],
                  ),
                ),
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
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _showVariantNameDialog();
                          }); // Ferme la boîte de dialogue
                        },
                        child: const Text('Variant\'s name'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showDeleteVariantDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Variant'),
          content: const Text("Are you sure to want to delete variant from the last played move ?"),
          actions: [
            Column(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await DatabaseHelper().deleteOpeningMoveAndDescendants(lastMoveId);
                          String message = "Variant deleted succesfully.";
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(message),
                          ));
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
    _resetBoard();
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

  void _showVariantNameDialog() {
    TextEditingController textFieldController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Variant name'),
          content: TextField(
            controller: textFieldController,
            decoration: const InputDecoration(hintText: "Enter variant name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  String input = textFieldController.text;
                  variantName = input;
                });
                _showValidateVariantDialog();
              },
              child: const Text('Ok'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showValidateVariantDialog(); // Ferme la boîte de dialogue
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
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
    lastMoveToRow = moveHistory.isNotEmpty ? moveHistory.last[1]?.row : null;
    lastMoveToCol = moveHistory.isNotEmpty ? moveHistory.last[1].col : null;
    _updateBoard();
  }

  void _playNextUniqueMove(){
    List<OpeningMove> move = widget.opening.moves
        .where((move) =>
    move.moveNumber == widget.board.moveCount.value &&
        move.previousMoveId == lastMoveId).toList();
    if (move.length != 1){
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
        .length == 1;
    Color whiteColor = isRecording
        ? const Color.fromRGBO(255, 216, 216, 1.0)
        : const Color.fromRGBO(246, 238, 228, 1.0);
    Color blackColor =
        isRecording ? const Color.fromRGBO(200, 0, 0, 1.0) : const Color.fromRGBO(201, 181, 151, 1.0);
    return Scaffold(
      body: Stack(
        children: [
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
              Stack(
                children: [
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
                        onPressed: isNextMoveUnique ? _playNextUniqueMove : null,
                        disabledColor: Colors.grey,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 9,
                ),
                Text(widget.opening.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic)),
                if (!isRecording)
                  Text(variantName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const LeftCoordinatesComponent(),
                    Column(
                      children: [
                        const SizedBox(height: 35),
                        Container(
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 8,
                                  ),
                                  itemBuilder: (context, index) {
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
                                    bool isLastFromSquare = square.row == lastMoveFromRow && square.col == lastMoveFromCol;
                                    bool isLastToSquare = square.row == lastMoveToRow && square.col == lastMoveToCol;
                                    Color lastMoveColor = isRecording ? Color.fromRGBO(255, 165, 0, 1.0) : Color.fromRGBO(173, 216, 230, 1.0);
                                    Color squareColor = square.isWhite ? whiteColor : blackColor;
                                    squareColor = isLastFromSquare || isLastToSquare ? lastMoveColor : squareColor;
                                    return GestureDetector(
                                      onTap: () {
                                        if (isGameOver) return;
                                        setState(() {
                                          if (!isRecording) {
                                            if (selectedSquare == null &&
                                                square.piece != null &&
                                                square.piece!.color ==
                                                    widget.board.currentTurn) {
                                              selectedSquare = square;
                                              validMoves = widget.board
                                                  .getValidMoves(square.piece!);
                                            } else if (selectedSquare != null &&
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
                                                    widget.board.currentTurn) {
                                              selectedSquare = square;
                                              validMoves = widget.board
                                                  .getValidMoves(square.piece!);
                                            } else if (selectedSquare != null &&
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
                                                lastMoveFromRow = selectedSquare!.row;
                                                lastMoveFromCol = selectedSquare!.col;
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
                                                color: Colors.black.withOpacity(0.5),
                                                width: 1,
                                              ),
                                                  color: squareColor),
                                            child: _buildPiece(square.piece),
                                          )
                                              : Container(
                                            decoration: BoxDecoration(
                                                    color: squareColor),
                                            child: _buildPiece(square.piece),
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
                                                  color: Colors.deepPurple
                                                      .withOpacity(0.9),
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
                                                decoration: const BoxDecoration(
                                                  color: Color.fromRGBO(108, 0, 0, 0.9),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          if (validMoves.contains(square) &&
                                              square.piece != null)
                                            Container(
                                              color: const Color.fromRGBO(255, 0, 0, 0.5),
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
                                          isReversed: isReversed),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                        const BottomCoordinatesComponent(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (!isRecording) {
                                  setState(() {
                                    isRecording = true;
                                  });
                                } else if (newVariant.isNotEmpty) {
                                  _showValidateVariantDialog();
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
                                  color: isRecording ? Colors.red : Colors.grey,
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
                            IconButton(onPressed: _showDeleteVariantDialog, icon: const Icon(
                              Icons.delete_outline, color: Colors.white,
                            ))
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
      if (doneMove.first.variantName.isNotEmpty) {
        variantName = doneMove.first.variantName;
      }
      return doneMove.first;
    } else {
      return null;
    }
  }

  Widget _buildPiece(Piece? piece) {
    if (piece == null) {
      return Container();
    }
    return Center(
      child: SvgPicture.asset(
        'assets/images/${pieceTypeToSVG(piece.type, piece.color)}',
        width: 60,
        height: 60,
      ),
    );
  }
}
