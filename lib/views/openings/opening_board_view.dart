import 'package:chess_ouvertures/components/captured_pieces_component.dart';
import 'package:chess_ouvertures/components/left_coordinates_component.dart';
import 'package:chess_ouvertures/components/bottom_coordinates_component.dart';
import 'package:chess_ouvertures/constants.dart';
import 'package:chess_ouvertures/model/openings/opening.dart';
import 'package:chess_ouvertures/views/main_view.dart';
import 'package:chess_ouvertures/views/openings/opening_main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../database/database_helper.dart';
import '../../model/board.dart';
import '../../model/openings/opening_move.dart';
import '../../model/piece.dart';
import '../../model/square.dart';
import '../../painter.dart';
import '../board_view.dart';
import '../database_main_view.dart';

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
                SizedBox(
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
                              .insertVariant(
                              newVariant, widget.opening.name);
                          String message = "";
                          if (result != null && result.isNotEmpty) {
                            for (OpeningMove move in result) {
                              setState(() {
                                widget.opening.moves.add(move);
                              });
                            }
                            message = "Added ${result.length} moves successfully.";
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
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
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

  String indexes(int index, bool isReversed){
    String res = "";
    // 0,8,16,32,40,48,56,57,58,59,60,61,62,63
    switch(index){
      case 0:
        res = isReversed ? "1" : "8";
        break;
      case 8:
        res = isReversed ? "2" : "7";
        break;
      case 16:
        res = isReversed ? "3" : "6";
        break;
      case 24:
        res = isReversed ? "4" : "5";
        break;
      case 32:
        res = isReversed ? "5" : "4";
        break;
      case 40:
        res = isReversed ? "6" : "3";
        break;
      case 48:
        res = isReversed ? "7" : "2";
        break;
      case 56:
        res = isReversed ? "8" : "1";
        break;
      case 57:
        res = isReversed ? "g" : "b";
        break;
      case 58:
        res = isReversed ? "f" : "c";
        break;
      case 59:
        res = isReversed ? "e" : "d";
        break;
      case 60:
        res = isReversed ? "d" : "e";
        break;
      case 61:
        res = isReversed ? "c" : "f";
        break;
      case 62:
        res = isReversed ? "b" : "g";
        break;
      case 63:
        res = isReversed ? "a" : "h";
        break;
      default: res = "0";
      break;
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    int currentMoveNumber = widget.board.moveCount.value;
    bool isNextMoveUnique = widget.opening.moves
        .where((move) =>
    move.moveNumber == currentMoveNumber &&
        move.previousMoveId == lastMoveId)
        .length == 1;
    Color bgColor = const Color.fromRGBO(60, 60, 60, 1);
    Color whiteColor = isRecording
        ? const Color.fromRGBO(255, 216, 216, 1.0)
        : const Color.fromRGBO(246, 238, 228, 1.0);
    Color blackColor =
        isRecording ? const Color.fromRGBO(200, 0, 0, 1.0) : const Color.fromRGBO(151, 131, 101, 1.0);
    Color textColor = whiteColor;
    int topScore = isReversed
        ? (widget.board.whiteScore - widget.board.blackScore)
        : (widget.board.blackScore - widget.board.whiteScore);
    int bottomScore = isReversed
        ? (widget.board.blackScore - widget.board.whiteScore)
        : (widget.board.whiteScore - widget.board.blackScore);
    List<int> coordinatesIndexes = [
      0,8,16,24,32,40,48,56,57,58,59,60,61,62,63
    ];
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: bgColor,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainView()),
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
                        onPressed: isNextMoveUnique ? _playNextUniqueMove : null,
                        disabledColor: Colors.grey,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  Center(
                    child: Text(widget.opening.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
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
                          const SizedBox(height: 35),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 4,
                                  color: Colors.black,
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
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8,
                                    ),
                                    itemBuilder: (context, index) {
                                      Color lastMoveColor = isRecording ? Color.fromRGBO(255, 165, 0, 1.0) : Color.fromRGBO(173, 216, 230, 1.0);
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
                                          ? whiteColor
                                          : blackColor;
                                      Color otherColor = !square.isWhite
                                          ? whiteColor
                                          : blackColor;
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
                                            if (coordinatesIndexes.contains(index))
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
                                                    fontWeight:
                                                    FontWeight.bold,
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
                                                    fontWeight:
                                                    FontWeight.bold,
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
                    child:
                    Column(
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
    return Center(
      child: SvgPicture.asset(
        'assets/images/${pieceTypeToSVG(piece.type, piece.color)}',
        width: 60,
        height: 60,
      ),
    );
  }
}
