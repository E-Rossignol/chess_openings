import 'dart:async';
import 'dart:math';
import 'package:chess_ouvertures/constants.dart';
import 'package:chess_ouvertures/model/square.dart';
import 'model/piece.dart';
import 'model/board.dart';

class Bot {
  final Board board;
  final PieceColor botColor;
  final Random rdm = Random();
  Timer? botTimer;

  Bot({required this.board, required this.botColor});

  void startGameAgainstBot() {
    botTimer?.cancel();
    botTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (board.currentTurn == botColor) {
        playRandomMove();
      }
    });
  }

  Future<void> playRandomMove() async {
    while (board.gameResult.value == 0) {
      List<Move> validMoves = getAllValidMoves();
      if (validMoves.isEmpty) {
        print('Game over');
        break;
      } else {
        Move selectedMove = selectPreferredMove(validMoves);
        board.movePiece(selectedMove.fromRow, selectedMove.fromCol,
            selectedMove.toRow, selectedMove.toCol);
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    }
    print("Simulation over");
  }

  List<Move> getAllValidMoves() {
    List<Move> validMoves = [];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        Square square = board.board[row][col];
        if (square.piece != null && square.piece!.color == botColor) {
          List<Square> moves = board.getValidMoves(square.piece!);
          for (Square move in moves) {
            validMoves.add(Move(
                fromRow: row,
                fromCol: col,
                toRow: move.row,
                toCol: move.col,
                capturedPiece: move.piece));
          }
        }
      }
    }
    return validMoves;
  }

  Move selectPreferredMove(List<Move> validMoves) {
    List<Move> capturingMoves =
    validMoves.where((move) => move.capturedPiece != null).toList();
    for (Move move in capturingMoves) {
      for (int i = 0; i < getValue(move.capturedPiece!); i++) {
        validMoves.add(move);
        validMoves.add(move);
        validMoves.add(move);
      }
    }
    return validMoves[rdm.nextInt(validMoves.length)];
  }

}

class Move {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  final Piece? capturedPiece;

  Move(
      {required this.fromRow,
        required this.fromCol,
        required this.toRow,
        required this.toCol,
        this.capturedPiece});
}