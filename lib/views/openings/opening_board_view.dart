import 'package:chess_ouvertures/constants.dart';
import 'package:chess_ouvertures/model/openings/opening.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../model/board.dart';
import '../../model/openings/opening_move.dart';
import '../../model/piece.dart';
import '../../model/square.dart';
import '../main_view.dart';

class OpeningBoardView extends StatefulWidget {
  final Board board;
  Opening opening;

  OpeningBoardView({super.key, required this.board, required this.opening});

  @override
  _OpeningBoardViewState createState() => _OpeningBoardViewState();
}

class _OpeningBoardViewState extends State<OpeningBoardView> {
  int? fromRow;
  int? fromCol;
  int? lastMoveFromRow;
  int? lastMoveFromCol;
  int? lastMoveToRow;
  int? lastMoveToCol;
  List<Square> validMoves = [];
  bool isReversed = false;
  Square? selectedSquare;
  String moveCountMessage = '0';
  List<OpeningMove>? allMoves;

  @override
  void initState() {
    super.initState();
    widget.board.boardNotifier.addListener(_updateBoard);
    widget.board.moveCount.addListener(_updateMoveCount);
    allMoves = widget.opening.moves;
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
      validMoves = [];
      lastMoveFromRow = null;
      lastMoveFromCol = null;
      lastMoveToRow = null;
      lastMoveToCol = null;
      selectedSquare = null;
    });
  }

  void _reverseBoard() {
    setState(() {
      isReversed = !isReversed;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              SizedBox(height: 50),
              Center(child: Text(widget.opening.name, style: TextStyle(color: Colors.white, fontSize: 30, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold))),
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
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Column(
                      children: List.generate(8, (index) {
                        return Container(
                          height: (MediaQuery.of(context).size.width - 25)/8,
                          padding: const EdgeInsets.only(bottom: 25, right: 10),
                          alignment: Alignment.center,
                          child: Text(
                            '${8 - index}',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }),
                    ),
                    Column(
                      children: [
                        Container(
                          color: Colors.blueAccent,
                          height: MediaQuery.of(context).size.width - 25,
                          width: MediaQuery.of(context).size.width - 25,
                          child: Center(
                            child: MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              removeBottom: true,
                              removeLeft: true,
                              removeRight: true,
                              child: GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 8,
                                ),
                                itemBuilder: (context, index) {
                                  final int row = isReversed
                                      ? 7 - (index ~/ 8)
                                      : index ~/ 8;
                                  final int col =
                                  isReversed ? 7 - (index % 8) : index % 8;
                                  final Square square =
                                  widget.board.board[row][col];
                                  bool isOriginSquare =
                                      fromRow == row && fromCol == col;
                                  bool isGameOver =
                                      widget.board.gameResult.value != 0;
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
                                          widget.board.movePiece(
                                            selectedSquare!.row,
                                            selectedSquare!.col,
                                            row,
                                            col,
                                          );
                                          selectedSquare = null;
                                          validMoves = [];
                                        }
                                        else {
                                          selectedSquare = null;
                                          validMoves = [];
                                        }
                                      });
                                    },
                                    child: DragTarget<Square>(
                                      onAccept: (data) {
                                        if (!isGameOver) {
                                          setState(() {
                                            widget.board.movePiece(
                                              data.row,
                                              data.col,
                                              row,
                                              col,
                                            );
                                            validMoves = [];
                                            fromRow = null;
                                            fromCol = null;
                                            lastMoveFromRow = data.row;
                                            lastMoveFromCol = data.col;
                                            lastMoveToRow = row;
                                            lastMoveToCol = col;
                                          });
                                        }
                                      },
                                      builder: (context, candidateData,
                                          rejectedData) {
                                        bool isValidMove =
                                        validMoves.contains(square);
                                        BoxDecoration squareDecoration = square
                                            .isWhite
                                            ? const BoxDecoration(
                                          color: Color.fromRGBO(
                                              246, 238, 228, 1.0),
                                        )
                                            : const BoxDecoration(
                                          color: Color.fromRGBO(
                                              201, 181, 151, 1.0),
                                        );
                                        return Stack(
                                          children: [
                                            Container(
                                              decoration: squareDecoration,
                                              child: square.piece != null &&
                                                  square.piece!.color ==
                                                      widget
                                                          .board.currentTurn
                                                  ? Draggable<Square>(
                                                data: square,
                                                feedback: _buildPiece(
                                                    square.piece!,
                                                    isDragging: true),
                                                childWhenDragging:
                                                Container(),
                                                child: _buildPiece(
                                                    square.piece!),
                                                onDragStarted: () {
                                                  if (!isGameOver) {
                                                    setState(() {
                                                      fromRow = row;
                                                      fromCol = col;
                                                      validMoves = widget
                                                          .board
                                                          .getValidMoves(
                                                          square
                                                              .piece!);
                                                    });
                                                  }
                                                },
                                                onDraggableCanceled:
                                                    (_, __) {
                                                  setState(() {
                                                    fromRow = null;
                                                    fromCol = null;
                                                    validMoves = [];
                                                  });
                                                },
                                              )
                                                  : _buildPiece(square.piece),
                                            ),
                                            if (isOriginSquare)
                                              Container(
                                                color: Colors.blue
                                                    .withOpacity(0.5),
                                              ),
                                            if (isValidMove &&
                                                square.piece == null)
                                              Center(
                                                child: Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: Colors.lightGreen
                                                        .withOpacity(0.9),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            if (isValidMove &&
                                                square.piece != null)
                                              Container(
                                                color:
                                                Colors.red.withOpacity(0.5),
                                              ),
                                          ],
                                        );

                                      },
                                    ),
                                  );
                                },
                                itemCount: 64,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(8, (index) {
                            return Container(
                              width: (MediaQuery.of(context).size.width - 25)/8,
                              alignment: Alignment.center,
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                        ),
                        if(widget.board.gameResult.value != 0)
                          const SizedBox(
                            height: 50,
                            child: Center(
                              child: Text("Game over !", style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ))
                            ),
                          ),

                        if(widget.board.gameResult.value == 0)
                          const SizedBox(height: 50),

                        TextButton(onPressed: (){
                          _showMoves();
                        }, child: Text("Available moves")),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              'Move n°$moveCountMessage', style: TextStyle(
              color: Colors.white,
            ),
            )
          )
        ],
      ),
    );
  }

  void _showMoves() {
    int currentMoveNumber = widget.board.moveCount.value;
    List<OpeningMove> availableMoves = allMoves?.where((move) => move.moveNumber == currentMoveNumber).toList() ?? [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Available Moves' ,style: TextStyle(
              color: Colors.black
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableMoves.map((move) {
              return ListTile(
                title: Text('${squareToString(move.from)} -> ${squareToString(move.to)}'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPiece(Piece? piece, {bool isDragging = false}) {
    if (piece == null) {
      return Container();
    }
    return Center(
      child: SvgPicture.asset(
        'assets/images/${pieceTypeToSVG(piece.type, piece.color)}',
        width: isDragging ? 70 : 60,
        height: isDragging ? 70 : 60,
      ),
    );
  }
}
