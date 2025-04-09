// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
import 'package:chess_ouvertures/model/piece.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/constants.dart';
import 'square.dart';

class Board {
  final List<List<Square>> board;
  ValueNotifier<bool> boardNotifier = ValueNotifier(false);
  ValueNotifier<List<Piece>> capturedPieceNotifier = ValueNotifier([]);
  PieceColor currentTurn = PieceColor.white;
  int whiteScore = 0;
  int blackScore = 0;
  ValueNotifier<int> gameResult = ValueNotifier<int>(
      0); // 0: ongoing, 1: white wins, 2: black wins, 3: draw
  Square? lastMoveFrom;
  Square? lastMoveTo;
  final AudioPlayer _audioPlayer = AudioPlayer();
  ValueNotifier<int> moveCount = ValueNotifier<int>(0);

  Board()
      : board = List.generate(
            8, (row) => List.generate(8, (col) => Square(row, col))) {
    // Initialize pieces on the board
    moveCount.value = 0;
    _initializePieces();
  }

  void undoLastMove(List<List<Square>> history) {
    reset();
    for (List<Square> move in history) {
      movePiece(move[0].row, move[0].col, move[1].row, move[1].col);
    }
    moveCount.value = moveCount.value;
    boardNotifier.value = boardNotifier.value;
  }

  List<Square> getValidMoves(Piece piece,
      {bool checkCheck = true, bool excludeKing = false}) {
    List<Square> validMoves = [];
    Square originSquare = findPiece(piece)!;
    switch (piece.type) {
      case PieceType.pawn:
        int direction = piece.color == PieceColor.white ? -1 : 1;
        if (isValidPosition(originSquare.row + direction, originSquare.col) &&
            board[originSquare.row + direction][originSquare.col].piece ==
                null) {
          validMoves.add(board[originSquare.row + direction][originSquare.col]);
          if ((piece.color == PieceColor.white && originSquare.row == 6) ||
              (piece.color == PieceColor.black && originSquare.row == 1)) {
            if (isValidPosition(
                    originSquare.row + 2 * direction, originSquare.col) &&
                board[originSquare.row + 2 * direction][originSquare.col]
                        .piece ==
                    null) {
              validMoves.add(
                  board[originSquare.row + 2 * direction][originSquare.col]);
            }
          }
        }
        if (isValidPosition(
                originSquare.row + direction, originSquare.col - 1) &&
            board[originSquare.row + direction][originSquare.col - 1].piece !=
                null &&
            board[originSquare.row + direction][originSquare.col - 1]
                    .piece!
                    .color !=
                piece.color) {
          validMoves
              .add(board[originSquare.row + direction][originSquare.col - 1]);
        }
        if (isValidPosition(
                originSquare.row + direction, originSquare.col + 1) &&
            board[originSquare.row + direction][originSquare.col + 1].piece !=
                null &&
            board[originSquare.row + direction][originSquare.col + 1]
                    .piece!
                    .color !=
                piece.color) {
          validMoves
              .add(board[originSquare.row + direction][originSquare.col + 1]);
        }
        break;

      case PieceType.rook:
        // Move up
        for (int i = originSquare.row - 1; i >= 0; i--) {
          if (board[i][originSquare.col].piece == null) {
            validMoves.add(board[i][originSquare.col]);
          } else {
            if (board[i][originSquare.col].piece!.color != piece.color) {
              validMoves.add(board[i][originSquare.col]);
            }
            // When the rook meets a piece, it can't move further
            break;
          }
        }
        // Move down
        for (int i = originSquare.row + 1; i < 8; i++) {
          if (board[i][originSquare.col].piece == null) {
            validMoves.add(board[i][originSquare.col]);
          } else {
            if (board[i][originSquare.col].piece!.color != piece.color) {
              validMoves.add(board[i][originSquare.col]);
            }
            break;
          }
        }
        // Move left
        for (int i = originSquare.col - 1; i >= 0; i--) {
          if (board[originSquare.row][i].piece == null) {
            validMoves.add(board[originSquare.row][i]);
          } else {
            if (board[originSquare.row][i].piece!.color != piece.color) {
              validMoves.add(board[originSquare.row][i]);
            }
            break;
          }
        }
        // Move horizontally right
        for (int i = originSquare.col + 1; i < 8; i++) {
          if (board[originSquare.row][i].piece == null) {
            validMoves.add(board[originSquare.row][i]);
          } else {
            if (board[originSquare.row][i].piece!.color != piece.color) {
              validMoves.add(board[originSquare.row][i]);
            }
            break;
          }
        }
        break;

      case PieceType.knight:
        // Define all possible moves for the knight
        List<List<int>> knightMoves = [
          [2, 1],
          [2, -1],
          [-2, 1],
          [-2, -1],
          [1, 2],
          [1, -2],
          [-1, 2],
          [-1, -2]
        ];
        for (var move in knightMoves) {
          int newRow = originSquare.row + move[0];
          int newCol = originSquare.col + move[1];
          // Check if the move is within the bounds of the board
          if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
            Square targetSquare = board[newRow][newCol];
            // Check if the target square is empty or contains an opponent's piece
            if (targetSquare.piece == null ||
                targetSquare.piece!.color != piece.color) {
              validMoves.add(targetSquare);
            }
          }
        }
        break;

      case PieceType.bishop:
        // Move diagonally up-left
        for (int i = 1;
            originSquare.row - i >= 0 && originSquare.col - i >= 0;
            i++) {
          if (board[originSquare.row - i][originSquare.col - i].piece == null) {
            validMoves.add(board[originSquare.row - i][originSquare.col - i]);
          } else {
            if (board[originSquare.row - i][originSquare.col - i]
                    .piece!
                    .color !=
                piece.color) {
              validMoves.add(board[originSquare.row - i][originSquare.col - i]);
            }
            break;
          }
        }
        // Move diagonally up-right
        for (int i = 1;
            originSquare.row - i >= 0 && originSquare.col + i < 8;
            i++) {
          if (board[originSquare.row - i][originSquare.col + i].piece == null) {
            validMoves.add(board[originSquare.row - i][originSquare.col + i]);
          } else {
            if (board[originSquare.row - i][originSquare.col + i]
                    .piece!
                    .color !=
                piece.color) {
              validMoves.add(board[originSquare.row - i][originSquare.col + i]);
            }
            break;
          }
        }
        // Move diagonally down-left
        for (int i = 1;
            originSquare.row + i < 8 && originSquare.col - i >= 0;
            i++) {
          if (board[originSquare.row + i][originSquare.col - i].piece == null) {
            validMoves.add(board[originSquare.row + i][originSquare.col - i]);
          } else {
            if (board[originSquare.row + i][originSquare.col - i]
                    .piece!
                    .color !=
                piece.color) {
              validMoves.add(board[originSquare.row + i][originSquare.col - i]);
            }
            break;
          }
        }
        // Move diagonally down-right
        for (int i = 1;
            originSquare.row + i < 8 && originSquare.col + i < 8;
            i++) {
          if (board[originSquare.row + i][originSquare.col + i].piece == null) {
            validMoves.add(board[originSquare.row + i][originSquare.col + i]);
          } else {
            if (board[originSquare.row + i][originSquare.col + i]
                    .piece!
                    .color !=
                piece.color) {
              validMoves.add(board[originSquare.row + i][originSquare.col + i]);
            }
            break;
          }
        }
        break;

      case PieceType.queen:
        // Combine rook and bishop moves
        // Rook moves
        // Move vertically up
        for (int i = originSquare.row - 1; i >= 0; i--) {
          if (board[i][originSquare.col].piece == null) {
            validMoves.add(board[i][originSquare.col]);
          } else {
            if (board[i][originSquare.col].piece!.color != piece.color) {
              validMoves.add(board[i][originSquare.col]);
            }
            break;
          }
        }
        // Move vertically down
        for (int i = originSquare.row + 1; i < 8; i++) {
          if (board[i][originSquare.col].piece == null) {
            validMoves.add(board[i][originSquare.col]);
          } else {
            if (board[i][originSquare.col].piece!.color != piece.color) {
              validMoves.add(board[i][originSquare.col]);
            }
            break;
          }
        }
        // Move horizontally left
        for (int i = originSquare.col - 1; i >= 0; i--) {
          if (board[originSquare.row][i].piece == null) {
            validMoves.add(board[originSquare.row][i]);
          } else {
            if (board[originSquare.row][i].piece!.color != piece.color) {
              validMoves.add(board[originSquare.row][i]);
            }
            break;
          }
        }
        // Move horizontally right
        for (int i = originSquare.col + 1; i < 8; i++) {
          if (board[originSquare.row][i].piece == null) {
            validMoves.add(board[originSquare.row][i]);
          } else {
            if (board[originSquare.row][i].piece!.color != piece.color) {
              validMoves.add(board[originSquare.row][i]);
            }
            break;
          }
        }
        // Bishop moves
        // Move diagonally up-left
        for (int i = 1;
            originSquare.row - i >= 0 && originSquare.col - i >= 0;
            i++) {
          if (board[originSquare.row - i][originSquare.col - i].piece == null) {
            validMoves.add(board[originSquare.row - i][originSquare.col - i]);
          } else {
            if (board[originSquare.row - i][originSquare.col - i]
                    .piece!
                    .color !=
                piece.color) {
              validMoves.add(board[originSquare.row - i][originSquare.col - i]);
            }
            break;
          }
        }
        // Move diagonally up-right
        for (int i = 1;
            originSquare.row - i >= 0 && originSquare.col + i < 8;
            i++) {
          if (board[originSquare.row - i][originSquare.col + i].piece == null) {
            validMoves.add(board[originSquare.row - i][originSquare.col + i]);
          } else {
            if (board[originSquare.row - i][originSquare.col + i]
                    .piece!
                    .color !=
                piece.color) {
              validMoves.add(board[originSquare.row - i][originSquare.col + i]);
            }
            break;
          }
        }
        // Move diagonally down-left
        for (int i = 1;
            originSquare.row + i < 8 && originSquare.col - i >= 0;
            i++) {
          if (board[originSquare.row + i][originSquare.col - i].piece == null) {
            validMoves.add(board[originSquare.row + i][originSquare.col - i]);
          } else {
            if (board[originSquare.row + i][originSquare.col - i]
                    .piece!
                    .color !=
                piece.color) {
              validMoves.add(board[originSquare.row + i][originSquare.col - i]);
            }
            break;
          }
        }
        // Move diagonally down-right
        for (int i = 1;
            originSquare.row + i < 8 && originSquare.col + i < 8;
            i++) {
          if (board[originSquare.row + i][originSquare.col + i].piece == null) {
            validMoves.add(board[originSquare.row + i][originSquare.col + i]);
          } else {
            if (board[originSquare.row + i][originSquare.col + i]
                    .piece!
                    .color !=
                piece.color) {
              validMoves.add(board[originSquare.row + i][originSquare.col + i]);
            }
            break;
          }
        }
        break;

      case PieceType.king:
        if (excludeKing) {
          break;
        }
        // Define all possible moves for the king
        List<List<int>> kingMoves = [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1],
          [1, 1],
          [1, -1],
          [-1, 1],
          [-1, -1]
        ];
        for (var move in kingMoves) {
          int newRow = originSquare.row + move[0];
          int newCol = originSquare.col + move[1];
          // Check if the move is within the bounds of the board
          if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
            Square targetSquare = board[newRow][newCol];
            // Check if the target square is empty or contains an opponent's piece
            if (targetSquare.piece == null ||
                targetSquare.piece!.color != piece.color) {
              validMoves.add(targetSquare);
            }
          }
        }
        // Castling logic
        if (originSquare.row == (piece.color == PieceColor.white ? 7 : 0) &&
            originSquare.col == 4 &&
            !piece.hasMove) {
          // Check for kingside castling
          if (board[originSquare.row][5].piece == null &&
              board[originSquare.row][6].piece == null &&
              board[originSquare.row][7].piece != null &&
              board[originSquare.row][7].piece!.type == PieceType.rook &&
              board[originSquare.row][7].piece!.color == piece.color &&
              !isThreatened(board[originSquare.row][5], piece.color,
                  excludeKing: true) &&
              !isThreatened(board[originSquare.row][6], piece.color,
                  excludeKing: true)) {
            validMoves.add(board[originSquare.row][6]);
          }
          // Check for queenside castling
          if (board[originSquare.row][1].piece == null &&
              board[originSquare.row][2].piece == null &&
              board[originSquare.row][3].piece == null &&
              board[originSquare.row][0].piece != null &&
              board[originSquare.row][0].piece!.type == PieceType.rook &&
              board[originSquare.row][0].piece!.color == piece.color &&
              !isThreatened(board[originSquare.row][1], piece.color,
                  excludeKing: true) &&
              !isThreatened(board[originSquare.row][2], piece.color,
                  excludeKing: true) &&
              !isThreatened(board[originSquare.row][3], piece.color,
                  excludeKing: true)) {
            validMoves.add(board[originSquare.row][2]);
          }
        }
        break;
    }
    for (var move in validMoves) {
      if (!isValidPosition(move.row, move.col)) {
        validMoves.remove(move);
        continue;
      }
    }
    // Check if the move puts the king in check
    if (checkCheck) {
      List<Square> validMovesCopy = List.from(validMoves);
      for (var move in validMovesCopy) {
        // Simulate the move
        var originalPiece = move.piece;
        var fromSquare = board[originSquare.row][originSquare.col];
        fromSquare.piece = null;
        move.piece = piece;
        // Check if the move puts the king in check
        if (isCheck(piece.color, checkCheck: false)) {
          validMoves.remove(move);
        }
        // Undo the move
        fromSquare.piece = piece;
        move.piece = originalPiece;
      }
    }
    return validMoves;
  }

  bool isValidPosition(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  bool isThreatened(Square square, PieceColor threatened,
      {bool checkCheck = false, bool excludeKing = false}) {
    List<Square> opponentPieces = [];
    PieceColor threat = toggleColor(threatened);
    for (var row in board) {
      for (var oppoSquare in row) {
        if (oppoSquare.piece == null) {
          continue;
        }
        if (oppoSquare.piece!.color == threat) {
          opponentPieces.add(oppoSquare);
        }
      }
    }
    for (var piece in opponentPieces) {
      if (getValidMoves(piece.piece!,
              checkCheck: checkCheck, excludeKing: excludeKing)
          .contains(square)) {
        return true;
      }
    }
    return false;
  }

  bool isCheck(PieceColor color, {bool checkCheck = false}) {
    Square? kingSquare;
    for (var row in board) {
      for (var square in row) {
        if (square.piece != null &&
            square.piece!.type == PieceType.king &&
            square.piece!.color == color) {
          kingSquare = square;
          break;
        }
      }
    }
    if (kingSquare == null) {
      return false;
    }
    return isThreatened(kingSquare, color, checkCheck: checkCheck);
  }

  bool isCheckmate() {
    // Get the current player's pieces
    List<Square> currentPlayerPieces = [];
    for (var row in board) {
      for (var square in row) {
        if (square.piece != null && square.piece!.color == currentTurn) {
          currentPlayerPieces.add(square);
        }
      }
    }
    // Check if any move can remove the check
    for (var pieceSquare in currentPlayerPieces) {
      var playerPiece = pieceSquare.piece!;
      for (var row in board) {
        for (var square in row) {
          if (getValidMoves(playerPiece, checkCheck: false).contains(square)) {
            // Simulate the move
            var originalPiece = square.piece;
            var fromSquare = board[pieceSquare.row][pieceSquare.col];
            fromSquare.piece = null;
            square.piece = playerPiece;
            // Check if the move removes the check
            if (!isCheck(currentTurn, checkCheck: false)) {
              // Undo the move
              fromSquare.piece = playerPiece;
              square.piece = originalPiece;
              return false;
            }
            // Undo the move
            fromSquare.piece = playerPiece;
            square.piece = originalPiece;
          }
        }
      }
    }
    // If no valid move can remove the check, it's checkmate
    return true;
  }

  Square? findPiece(Piece piece) {
    for (var row in board) {
      for (var square in row) {
        if (square.piece != null && square.piece!.id == piece.id) {
          return square;
        }
      }
    }
    return null;
  }

  bool movePiece(int fromRow, int fromCol, int toRow, int toCol) {
    String toPlay = "";
    bool castling = false;
    final piece = board[fromRow][fromCol].piece;
    if (piece != null && piece.color == currentTurn) {
      List<Square> validMoves = getValidMoves(piece, checkCheck: true);
      if (validMoves.contains(board[toRow][toCol])) {
        // Check if it's a castle move
        if (piece.type == PieceType.king &&
            fromRow == (piece.color == PieceColor.white ? 7 : 0) &&
            fromCol == 4 &&
            (toCol == 2 || toCol == 6)) {
          castling = true;
          // Kingside castle
          if (toCol == 6) {
            board[toRow][5].piece = board[toRow][7].piece;
            board[toRow][7].piece = null;
          }
          // Queenside castle
          if (toCol == 2) {
            board[toRow][3].piece = board[toRow][0].piece;
            board[toRow][0].piece = null;
          }
        }
        final captured = board[toRow][toCol].piece;
        if (captured != null) {
          toPlay = 'capture.mp3';
          capturedPieceNotifier.value.add(captured);
          _updateScore(captured);
          findPiece(captured)!.piece = null;
        } else {
          toPlay = 'move.mp3';
        }
        board[toRow][toCol].piece = piece;
        board[fromRow][fromCol].piece = null;

        lastMoveFrom = board[fromRow][fromCol];
        lastMoveTo = board[toRow][toCol];
        currentTurn = toggleColor(currentTurn);
        if (isCheck(currentTurn)) {
          if (isCheckmate()) {
            gameResult.value = currentTurn == PieceColor.white ? 2 : 1;
            toPlay = 'check_mate.mp3';
          } else {
            toPlay = 'check.mp3';
          }
        }
        if (castling) {
          toPlay = 'castle.mp3';
        }
        _playSound(toPlay);
        boardNotifier.value = !boardNotifier.value;
        moveCount.value++;
        boardNotifier.notifyListeners();
        moveCount.notifyListeners();
        piece.hasMove = true;
        isDraw();
        return true;
      }
    }
    return false;
  }

  Future<void> _playSound(String fileName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isMuted = prefs.getBool('isMuted') ?? false;
    if (isMuted) {
      return;
    }
    await _audioPlayer.setVolume(60);
    await _audioPlayer.setAsset('assets/audio/$fileName');
    await _audioPlayer
        .setAudioSource(AudioSource.uri(Uri.parse('assets/audio/$fileName')));
    _audioPlayer.play();
  }

  void _updateScore(Piece captured) {
    if (captured.color == PieceColor.white) {
      blackScore += pieceValue(captured.type);
    } else {
      whiteScore += pieceValue(captured.type);
    }
  }

  void reset() {
    for (var row in board) {
      for (var square in row) {
        square.piece = null;
      }
    }
    moveCount.value = 0;
    _initializePieces();
    capturedPieceNotifier.value.clear();
    currentTurn = PieceColor.white;
    gameResult.value = 0;
    whiteScore = 0;
    blackScore = 0;
    lastMoveFrom = null;
    lastMoveTo = null;
  }

  void isDraw() {
    List<Piece> remainingPieces = [];
    for (var row in board) {
      for (var square in row) {
        if (square.piece != null) {
          remainingPieces.add(square.piece!);
        }
      }
    }
    if (remainingPieces.length == 2 &&
        remainingPieces.elementAt(0).type == PieceType.king &&
        remainingPieces.elementAt(1).type == PieceType.king) {
      gameResult.value = -1;
    }
    List<List<Square>> moves = [];
    for (var row in board) {
      for (var square in row) {
        if (square.piece != null && square.piece!.color == currentTurn) {
          moves.add(getValidMoves(square.piece!));
        }
      }
    }
    moves.removeWhere((element) => element.isEmpty);
    if (moves.isEmpty && !isCheck(currentTurn)) {
      gameResult.value = -1;
    }
  }

  void _initializePieces() {
    Piece whitePawn1 = Piece(
        type: PieceType.pawn, color: PieceColor.white, id: 1, hasMove: false);
    Piece whitePawn2 = Piece(
        type: PieceType.pawn, color: PieceColor.white, id: 2, hasMove: false);
    Piece whitePawn3 = Piece(
        type: PieceType.pawn, color: PieceColor.white, id: 3, hasMove: false);
    Piece whitePawn4 = Piece(
        type: PieceType.pawn, color: PieceColor.white, id: 4, hasMove: false);
    Piece whitePawn5 = Piece(
        type: PieceType.pawn, color: PieceColor.white, id: 5, hasMove: false);
    Piece whitePawn6 = Piece(
        type: PieceType.pawn, color: PieceColor.white, id: 6, hasMove: false);
    Piece whitePawn7 = Piece(
        type: PieceType.pawn, color: PieceColor.white, id: 7, hasMove: false);
    Piece whitePawn8 = Piece(
        type: PieceType.pawn, color: PieceColor.white, id: 8, hasMove: false);
    Piece whiteRook1 = Piece(
        type: PieceType.rook, color: PieceColor.white, id: 9, hasMove: false);
    Piece whiteRook2 = Piece(
        type: PieceType.rook, color: PieceColor.white, id: 10, hasMove: false);
    Piece whiteKnight1 = Piece(
        type: PieceType.knight,
        color: PieceColor.white,
        id: 11,
        hasMove: false);
    Piece whiteKnight2 = Piece(
        type: PieceType.knight,
        color: PieceColor.white,
        id: 12,
        hasMove: false);
    Piece whiteBishop1 = Piece(
        type: PieceType.bishop,
        color: PieceColor.white,
        id: 13,
        hasMove: false);
    Piece whiteBishop2 = Piece(
        type: PieceType.bishop,
        color: PieceColor.white,
        id: 14,
        hasMove: false);
    Piece whiteQueen = Piece(
        type: PieceType.queen, color: PieceColor.white, id: 15, hasMove: false);
    Piece whiteKing = Piece(
        type: PieceType.king, color: PieceColor.white, id: 16, hasMove: false);
    Piece blackPawn1 = Piece(
        type: PieceType.pawn, color: PieceColor.black, id: 17, hasMove: false);
    Piece blackPawn2 = Piece(
        type: PieceType.pawn, color: PieceColor.black, id: 18, hasMove: false);
    Piece blackPawn3 = Piece(
        type: PieceType.pawn, color: PieceColor.black, id: 19, hasMove: false);
    Piece blackPawn4 = Piece(
        type: PieceType.pawn, color: PieceColor.black, id: 20, hasMove: false);
    Piece blackPawn5 = Piece(
        type: PieceType.pawn, color: PieceColor.black, id: 21, hasMove: false);
    Piece blackPawn6 = Piece(
        type: PieceType.pawn, color: PieceColor.black, id: 22, hasMove: false);
    Piece blackPawn7 = Piece(
        type: PieceType.pawn, color: PieceColor.black, id: 23, hasMove: false);
    Piece blackPawn8 = Piece(
        type: PieceType.pawn, color: PieceColor.black, id: 24, hasMove: false);
    Piece blackRook1 = Piece(
        type: PieceType.rook, color: PieceColor.black, id: 25, hasMove: false);
    Piece blackRook2 = Piece(
        type: PieceType.rook, color: PieceColor.black, id: 26, hasMove: false);
    Piece blackKnight1 = Piece(
        type: PieceType.knight,
        color: PieceColor.black,
        id: 27,
        hasMove: false);
    Piece blackKnight2 = Piece(
        type: PieceType.knight,
        color: PieceColor.black,
        id: 28,
        hasMove: false);
    Piece blackBishop1 = Piece(
        type: PieceType.bishop,
        color: PieceColor.black,
        id: 29,
        hasMove: false);
    Piece blackBishop2 = Piece(
        type: PieceType.bishop,
        color: PieceColor.black,
        id: 30,
        hasMove: false);
    Piece blackQueen = Piece(
        type: PieceType.queen, color: PieceColor.black, id: 31, hasMove: false);
    Piece blackKing = Piece(
        type: PieceType.king, color: PieceColor.black, id: 32, hasMove: false);
    board[1][0].piece = blackPawn1;
    board[1][1].piece = blackPawn2;
    board[1][2].piece = blackPawn3;
    board[1][3].piece = blackPawn4;
    board[1][4].piece = blackPawn5;
    board[1][5].piece = blackPawn6;
    board[1][6].piece = blackPawn7;
    board[1][7].piece = blackPawn8;
    board[0][0].piece = blackRook1;
    board[0][7].piece = blackRook2;
    board[0][1].piece = blackKnight1;
    board[0][6].piece = blackKnight2;
    board[0][2].piece = blackBishop1;
    board[0][5].piece = blackBishop2;
    board[0][3].piece = blackQueen;
    board[0][4].piece = blackKing;
    board[6][0].piece = whitePawn1;
    board[6][1].piece = whitePawn2;
    board[6][2].piece = whitePawn3;
    board[6][3].piece = whitePawn4;
    board[6][4].piece = whitePawn5;
    board[6][5].piece = whitePawn6;
    board[6][6].piece = whitePawn7;
    board[6][7].piece = whitePawn8;
    board[7][0].piece = whiteRook1;
    board[7][7].piece = whiteRook2;
    board[7][1].piece = whiteKnight1;
    board[7][6].piece = whiteKnight2;
    board[7][2].piece = whiteBishop1;
    board[7][5].piece = whiteBishop2;
    board[7][3].piece = whiteQueen;
    board[7][4].piece = whiteKing;
  }
}
