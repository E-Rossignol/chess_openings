import 'dart:math';
import 'package:chess_openings/model/board.dart';
import 'package:chess_openings/model/piece.dart';
import 'constants.dart';

class StockfishHelper {
  Future<double> getAnalysisValue(Board board) async {
    Random rdm = Random();
    double randomValue = rdm.nextDouble() * 2 - 1;
    return randomValue;
  }

  String boardToFen(Board board) {
    String res = "";
    for (int i = 0; i < 8; i++) {
      int emptyCount = 0;
      for (int j = 0; j < 8; j++) {
        if (board.board[i][j].piece == null) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            res += emptyCount.toString();
            emptyCount = 0;
          }
          Piece p = board.board[i][j].piece!;
          if (p.type == PieceType.pawn) {
            res += p.color == PieceColor.white ? "P" : "p";
          } else if (p.type == PieceType.rook) {
            res += p.color == PieceColor.white ? "R" : "r";
          } else if (p.type == PieceType.knight) {
            res += p.color == PieceColor.white ? "N" : "n";
          } else if (p.type == PieceType.bishop) {
            res += p.color == PieceColor.white ? "B" : "b";
          } else if (p.type == PieceType.queen) {
            res += p.color == PieceColor.white ? "Q" : "q";
          } else if (p.type == PieceType.king) {
            res += p.color == PieceColor.white ? "K" : "k";
          }
        }
      }
      if (emptyCount > 0) {
        res += emptyCount.toString();
      }
      if (i < 7) {
        res += "/";
      }
    }
    res +=
        " ${board.currentTurn == PieceColor.white ? 'w' : 'b'} ${board.availableCastles()} - 0 ${board.moveCount.value}";
    return res;
  }
}
