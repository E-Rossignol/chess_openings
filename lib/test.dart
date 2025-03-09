import 'dart:math';
import 'package:chess_ouvertures/constants.dart';
import 'package:chess_ouvertures/model/square.dart';
import 'model/piece.dart';
import 'model/board.dart';

class Test {
  final Board board;
  PieceColor playing = PieceColor.white;
  bool _isRunning = false;
  Random rdm = Random();

  Test({required this.board});

  Future<void> runTest() async {
    _isRunning = true;
    try {
      await playRandomMoves();
    } catch (e) {
      print(e);
    }
  }

  void stopTest() {
    _isRunning = false;
  }

  Future<void> playRandomMoves() async {
    while (board.gameResult.value == 0) {
      if (!_isRunning) {
        print('Stopped');
        break;
      }
      List<Move> validMoves = getAllValidMoves();
      if (validMoves.isEmpty) {
        print('Game over');
        break;
      } else {
        Move selectedMove = selectPreferredMove(validMoves);
        board.movePiece(selectedMove.fromRow, selectedMove.fromCol,
            selectedMove.toRow, selectedMove.toCol);
        switchTurn();
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    print("Simulation over");
  }

  List<Move> getAllValidMoves() {
    List<Move> validMoves = [];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        Square square = board.board[row][col];
        if (square.piece != null && square.piece!.color == playing) {
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

  void switchTurn() {
    playing = toggleColor(playing);
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
