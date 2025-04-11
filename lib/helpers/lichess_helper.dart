import 'dart:math';

import 'package:chess_ouvertures/model/board.dart';
import 'package:chess_ouvertures/model/piece.dart';

import 'constants.dart';

class LichessHelper{
  Future<double> getAnalysisValue(Board board){
    String fen = boardToFen(board);
    Random rdm = Random();
    double value = rdm.nextDouble() * 20 - 10;
    return Future.value(value);
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
    res += " ${board.currentTurn == PieceColor.white ? 'w' : 'b'} KQkq - 0 ${board.moveCount.value}";
    return res;
  }
  }