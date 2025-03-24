// ignore_for_file: library_private_types_in_public_api

import 'package:chess_ouvertures/helpers/constants.dart';
import 'package:chess_ouvertures/services/bot_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../model/board.dart';
import '../model/piece.dart';
import '../model/square.dart';
import 'main_view.dart';

class BotView extends StatefulWidget {
  final Board board;
  final int difficulty;
  final bool isBotWhite;

  const BotView(
      {super.key,
      required this.board,
      required this.difficulty,
      required this.isBotWhite});

  @override
  _BotViewState createState() => _BotViewState();
}

class _BotViewState extends State<BotView> {
  int? fromRow;
  int? fromCol;
  int? lastMoveFromRow;
  int? lastMoveFromCol;
  int? lastMoveToRow;
  int? lastMoveToCol;
  List<Square> validMoves = [];
  bool isReversed = false;
  Square? selectedSquare;
  String gameResultMessage = '';
  String moveCountMessage = '';
  BotService api = BotService();
  String gameID = '';
  String lastMove = '';

  @override
  void initState() {
    super.initState();
    if (widget.isBotWhite) _reverseBoard();
    widget.board.gameResult.addListener(_updateGameResult);
    widget.board.boardNotifier.addListener(_updateBoard);
    widget.board.moveCount.addListener(_updateMoveCount);
    _initBot();
  }

  Future<void> _initBot() async {
    String? id = await api.createGame(widget.difficulty, widget.isBotWhite);
    if (id != null) {
      gameID = id;
      //Map<String, dynamic>? state = await api.getGameState(id);
    }
  }

  @override
  void dispose() {
    widget.board.gameResult.removeListener(_updateGameResult);
    widget.board.boardNotifier.removeListener(_updateBoard);
    super.dispose();
  }

  Future<void> _playMove(Square from, Square to) async {
    widget.board.movePiece(
      from.row,
      from.col,
      to.row,
      to.col,
    );
    _updateBoard();
    PieceColor botColor =
        widget.isBotWhite ? PieceColor.white : PieceColor.black;
    if (widget.board.currentTurn == botColor) {
      String currentMove = squareToString(from) + squareToString(to);
      await api.makeMove(gameID, currentMove);
    }
    lastMove = squareToString(from) + squareToString(to);
    bool botPlayed = false;
    while (!botPlayed) {
      botPlayed = await _listenBot();
      if (!botPlayed) {
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
  }

  Future<bool> _listenBot() async {
    Map<String, dynamic>? status = await api.getGameState(gameID);
    String moves = "";
    if (status != null) {
      moves = status['state']['moves'];
    }
    if (moves.isEmpty) return false;
    String lastBotMove = moves.substring(moves.length - 4);
    if (lastBotMove != lastMove) {
      Square from = stringToSquare(lastBotMove.substring(0, 2));
      Square to = stringToSquare(lastBotMove.substring(2, 4));
      await _playMove(from, to);
      return true;
    } else {
      return false;
    }
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
      lastMove = "";
      _initBot();
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
                              builder: (context) => MainView(key: UniqueKey())),
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
                          onPressed: () async {
                            await _listenBot();
                          },
                          icon: const Icon(
                              Icons
                                  .signal_wifi_statusbar_connected_no_internet_4,
                              color: Colors.white)),
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  child: isReversed ? whiteScore() : blackScore(),
                ),
                const SizedBox(height: 10),
                if (gameResultMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.black.withOpacity(0.7),
                    child: Text(
                      gameResultMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                Row(
                  children: [
                    Column(
                      children: List.generate(8, (index) {
                        return Container(
                          height: (MediaQuery.of(context).size.width - 25) / 8,
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
                                physics: const NeverScrollableScrollPhysics(),
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
                                          _playMove(selectedSquare!,
                                              Square(row, col));
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
                                        Container(
                                          decoration: square.isWhite
                                              ? const BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      246, 238, 228, 1.0),
                                                )
                                              : const BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      201, 181, 151, 1.0),
                                                ),
                                          child: _buildPiece(square.piece),
                                        ),
                                        if (isOriginSquare)
                                          Container(
                                            color: Colors.blue.withOpacity(0.5),
                                          ),
                                        if (validMoves.contains(square) &&
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
                                        if (validMoves.contains(square) &&
                                            square.piece != null)
                                          Container(
                                            color: Colors.red.withOpacity(0.5),
                                          ),
                                      ],
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
                              width:
                                  (MediaQuery.of(context).size.width - 25) / 8,
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
                      ],
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
                        'assets/images/${pieceTypeToSVG(type, pawn.color, 'classic')}',
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
        'assets/images/${pieceTypeToSVG(piece.type, piece.color, 'classic')}',
        width: 60,
        height: 60,
      ),
    );
  }
}
