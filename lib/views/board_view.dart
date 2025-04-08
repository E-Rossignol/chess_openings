// ignore_for_file: library_private_types_in_public_api

import 'package:chess_ouvertures/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../components/captured_pieces_component.dart';
import '../model/board.dart';
import '../model/piece.dart';
import '../model/square.dart';
import '../model/style_preferences.dart';

class BoardView extends StatefulWidget {
  final Board board;
  final StylePreferences stylePreferences = StylePreferences();

  BoardView({super.key, required this.board});

  @override
  _BoardViewState createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  int? lastMoveFromRow;
  int? lastMoveFromCol;
  int? lastMoveToRow;
  int? lastMoveToCol;
  List<Square> validMoves = [];
  bool isReversed = false;
  Square? selectedSquare;
  String moveCountMessage = '0';
  List<List<Square>> moveHistory = [];
  String gameResultMessage = '';
  Color whiteColor = Colors.white;
  Color blackColor = Colors.black;
  Color validMoveColor = Colors.deepPurple;
  Color lastColor = Colors.tealAccent;
  String pieceStyle = 'classic';
  List<Color> colors = [];

  @override
  void initState() {
    super.initState();
    _loadColorsFromPrefs();
    widget.board.boardNotifier.addListener(_updateBoard);
    widget.board.moveCount.addListener(_updateMoveCount);
    widget.board.gameResult.addListener(_updateGameResult);
    widget.stylePreferences.selectedColor.addListener(_updateColors);
    widget.stylePreferences.selectedStyle.addListener(_updateStyle);
  }

  @override
  void dispose() {
    widget.board.boardNotifier.removeListener(_updateBoard);
    widget.board.moveCount.removeListener(_updateMoveCount);
    widget.board.gameResult.removeListener(_updateGameResult);
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
      lastColor = colors[2];
    });
  }

  void _updateColors() {
    setState(
      () {
        colors = widget.stylePreferences.selectedColor.value;
        whiteColor = colors[0];
        blackColor = colors[1];
        lastColor = colors[2];
      },
    );
  }

  void _updateStyle() {
    setState(() {
      pieceStyle = widget.stylePreferences.selectedStyle.value;
    });
  }

  void _updateBoard() {
    setState(() {});
  }

  void _updateMoveCount() {
    setState(() {
      moveCountMessage = (widget.board.moveCount.value ~/ 2).toString();
    });
  }

  void _updateGameResult() {
    final result = widget.board.gameResult.value;
    setState(() {
      switch (result) {
        case 1:
          gameResultMessage = 'White wins!';
          break;
        case 2:
          gameResultMessage = 'Black wins!';
          break;
        case -1:
          gameResultMessage = 'Draw!';
          break;
        default:
          gameResultMessage = '';
      }
    });
    if (gameResultMessage != "") {
      showGameResultDialog();
    }
  }

  void _resetBoard() {
    setState(() {
      widget.board.reset();
      validMoves = [];
      lastMoveFromRow = null;
      lastMoveFromCol = null;
      lastMoveToRow = null;
      lastMoveToCol = null;
      selectedSquare = null;
      gameResultMessage = '';
      moveHistory.clear();
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

  void _undoLastMove() {
    if (moveHistory.isNotEmpty) {
      moveHistory.removeLast();
      widget.board.undoLastMove(moveHistory);
    }
    lastMoveFromRow = moveHistory.isNotEmpty ? moveHistory.last[0].row : null;
    lastMoveFromCol = moveHistory.isNotEmpty ? moveHistory.last[0].col : null;
    lastMoveToRow = moveHistory.isNotEmpty ? moveHistory.last[1].row : null;
    lastMoveToCol = moveHistory.isNotEmpty ? moveHistory.last[1].col : null;
    _updateBoard();
  }

  void showGameResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text(gameResultMessage),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Logique pour réinitialiser ou quitter la partie
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int currentMoveNumber = widget.board.moveCount.value;
    List<Color> bgColor = !isReversed
        ? [primaryThemeDarkColor, primaryThemeLightColor]
        : [primaryThemeLightColor, primaryThemeDarkColor];
    Color textColor = whiteColor;
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
            const SizedBox(
              height: 50,
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
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                      bool isLastFromSquare =
                                          square.row == lastMoveFromRow &&
                                              square.col == lastMoveFromCol;
                                      bool isLastToSquare =
                                          square.row == lastMoveToRow &&
                                              square.col == lastMoveToCol;
                                      Color lastMoveColor = lastColor;
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
                                            if (selectedSquare == null &&
                                                square.piece != null &&
                                                square.piece!.color ==
                                                    widget.board.currentTurn) {
                                              selectedSquare = square;
                                              validMoves = widget.board
                                                  .getValidMoves(square.piece!);
                                            } else if (selectedSquare != null &&
                                                validMoves.contains(square)) {
                                              bool isPromoting =
                                                  (selectedSquare!
                                                              .piece?.type ==
                                                          PieceType.pawn &&
                                                      ((row == 7 &&
                                                              selectedSquare!
                                                                      .piece
                                                                      ?.color ==
                                                                  PieceColor
                                                                      .black) ||
                                                          (row == 0 &&
                                                              selectedSquare!
                                                                      .piece
                                                                      ?.color ==
                                                                  PieceColor
                                                                      .white)));
                                              if (isPromoting) {
                                                _showPromotionDialog(
                                                    selectedSquare!.piece!,
                                                    widget.board,
                                                    row,
                                                    col);
                                              }
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
                                                    square.piece!.color))
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
                                                square.piece == null)
                                              Center(
                                                child: Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: validMoveColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            if (validMoves.contains(square) &&
                                                square.piece != null)
                                              Container(
                                                color: const Color.fromRGBO(
                                                    255, 0, 0, 0.5),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                    itemCount: 64,
                                  ),
                                ]),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
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
                  const SizedBox(height: 30),
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

  void _showPromotionDialog(Piece pawn, Board board, int row, int col) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Promote Pawn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: PieceType.values
                .where(
                    (type) => type != PieceType.king && type != PieceType.pawn)
                .map((type) => ListTile(
                      //title: Text(type.toString().split('.').last),
                      title: SvgPicture.asset(
                        'assets/images/${pieceTypeToSVG(type, pawn.color, pieceStyle)}',
                        width: 60,
                        height: 60,
                      ),
                      onTap: () {
                        setState(() {
                          board.board[row][col].piece = Piece(
                              type: type,
                              color: pawn.color,
                              id: pawn.id,
                              hasMove: true);
                        });
                        Navigator.of(context).pop();
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildPiece(Piece? piece) {
    if (piece == null) {
      return Container();
    }
    return Center(
      child: SvgPicture.asset(
        'assets/images/${pieceTypeToSVG(piece.type, piece.color, pieceStyle)}',
        width: 50,
        height: 50,
      ),
    );
  }
}
