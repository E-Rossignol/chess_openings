// lib/services/lichess_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class BotService {
  final String _baseUrl = 'https://lichess.org/api';
  final String _token = 'lip_O2LxxGz3ag4Cxn9C8CfA';

  Future<String?> createGame(int difficulty, bool isBotWhite) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/challenge/ai'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'level': difficulty,
        // Niveau du bot (1 à 8)
        'color': isBotWhite ? 'black' : 'white',
        // Couleur du joueur ('white', 'black', 'random')
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data['id']; // ID de la partie
    } else {
      print('Erreur lors de la création de la partie : ${response.body}');
      return null;
    }
  }

  Future<void> makeMove(String gameId, String move) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/board/game/$gameId/move/$move'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      print('Erreur lors de l\'envoi du mouvement : ${response.body}');
    }
  }

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
        if (e is FormatException && e.message == "Unexpected character"){
          await getGameState(gameId);
        }
      }
    } else {
      print(
          'Erreur lors de la récupération de l\'état de la partie : ${response.body}');
      return null;
    }
    return null;
  }
}
