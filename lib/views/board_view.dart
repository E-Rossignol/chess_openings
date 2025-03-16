import 'package:chess_ouvertures/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../components/bottom_coordinates_component.dart';
import '../components/captured_pieces_component.dart';
import '../components/left_coordinates_component.dart';
import '../model/board.dart';
import '../model/piece.dart';
import '../model/square.dart';
import '../test.dart';
import 'main_view.dart';

class BoardView extends StatefulWidget {
  final Board board;
  final PieceColor botColor;

  const BoardView({super.key, required this.board, this.botColor = PieceColor.black});

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

  @override
  void initState() {
    super.initState();
    widget.board.gameResult.addListener(_updateGameResult);
    widget.board.boardNotifier.addListener(_updateBoard);
    widget.board.moveCount.addListener(_updateMoveCount);
  }

  @override
  void dispose() {
    widget.board.gameResult.removeListener(_updateGameResult);
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
    if (gameResultMessage != ""){
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

  Widget whiteScore() {
    String score = "White score: ";
    score += '${(widget.board.whiteScore - widget.board.blackScore)}';
    return Text(
      score,
      style: const TextStyle(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  Widget blackScore() {
    String score = "Black score: ";
    score += '${(widget.board.blackScore - widget.board.whiteScore)}';
    return Text(
      score,
      style: const TextStyle(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  void _undoLastMove() {
    if (moveHistory.isNotEmpty) {
      moveHistory.removeLast();
      widget.board.undoLastMove(moveHistory);
    }
    lastMoveFromRow = moveHistory.isNotEmpty ? moveHistory.last[0].row : null;
    lastMoveFromCol = moveHistory.isNotEmpty ? moveHistory.last[0].col : null;
    lastMoveToRow = moveHistory.isNotEmpty ? moveHistory.last[1]?.row : null;
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
    Color whiteColor =  const Color.fromRGBO(246, 238, 228, 1.0);
    Color blackColor = const Color.fromRGBO(201, 181, 151, 1.0);
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
                              builder: (context) => const MainView()),
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
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height -5,
            width: MediaQuery.of(context).size.width -5,
            child: Center(
              child:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: isReversed ? whiteScore() : blackScore(),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: CapturedPiecesComponent(
                        capturedPieces: widget.board.capturedPieceNotifier.value.where((element) => element.color == (isReversed ? PieceColor.black: PieceColor.white)).toList(),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      Color lastMoveColor = const Color.fromRGBO(173, 216, 230, 1.0);
                                      Color squareColor = square.isWhite ? whiteColor : blackColor;
                                      squareColor = isLastFromSquare || isLastToSquare ? lastMoveColor : squareColor;
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
                                                bool isPromoting = (selectedSquare!
                                                    .piece?.type ==
                                                    PieceType.pawn &&
                                                    ((row == 7 &&
                                                        selectedSquare!
                                                            .piece?.color ==
                                                            PieceColor.black) ||
                                                        (row == 0 &&
                                                            selectedSquare!
                                                                .piece?.color ==
                                                                PieceColor.white)));
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
                                                square.piece == null)
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
                                ]),
                              ),
                            ),
                          ),
                          const BottomCoordinatesComponent(),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: CapturedPiecesComponent(
                            capturedPieces: widget.board.capturedPieceNotifier.value.where((element) => element.color == (isReversed ? PieceColor.white: PieceColor.black)).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: isReversed ? blackScore() : whiteScore(),
                  ),
                ],
              ),
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
                'assets/images/${pieceTypeToSVG(type, pawn.color)}',
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
        'assets/images/${pieceTypeToSVG(piece.type, piece.color)}',
        width: 60,
        height: 60,
      ),
    );
  }
}
