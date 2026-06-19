// lib/services/lichess_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class BotService {
  final String _baseUrl = 'https://lichess.org/api';
  final String _token = 'lip_O2LxxGz3ag4Cxn9C8CfA';

  /// Creates a new AI game on the remote service.
  ///
  /// @param difficulty level between 1 and 8
  /// @param isBotWhite true if the bot should play white
  /// @return Future<String?> game id when created or null on error
  Future<String?> createGame(int difficulty, bool isBotWhite) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/challenge/ai'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'level': difficulty,
        'color': isBotWhite ? 'black' : 'white',
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      print('Error creating game: ${response.body}');
      return null;
    }
  }

  /// Sends a move to the remote game.
  ///
  /// @param gameId id of the game
  /// @param move SAN or UCI move string
  Future<void> makeMove(String gameId, String move) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/board/game/$gameId/move/$move'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      print('Error sending move: ${response.body}');
    }
  }

  /// Streams or fetches the game state from the remote API.
  ///
  /// @param gameId id of the game to query
  /// @return Future<Map<String,dynamic>?> parsed JSON or null on error
  Future<Map<String, dynamic>?> getGameState(String gameId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/board/game/stream/$gameId'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        if (e is FormatException && e.message == "Unexpected character") {
          await getGameState(gameId);
        }
      }
    } else {
      print('Error fetching game state: ${response.body}');
      return null;
    }
    return null;
  }
}
