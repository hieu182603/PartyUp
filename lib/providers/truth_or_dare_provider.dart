import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/player.dart';
import '../models/game_content.dart';

class TruthOrDareProvider with ChangeNotifier {
  Player? _currentPlayer;
  GameContent? _currentContent;
  String _state = 'selecting_player'; // selecting_player, choosing_type, playing, result

  Player? get currentPlayer => _currentPlayer;
  GameContent? get currentContent => _currentContent;
  String get state => _state;

  final Random _random = Random();
  int? _lastPlayerId;

  void reset() {
    _currentPlayer = null;
    _currentContent = null;
    _state = 'selecting_player';
    _lastPlayerId = null;
    notifyListeners();
  }

  void selectRandomPlayer(List<Player> players) {
    if (players.isEmpty) return;
    
    List<Player> availablePlayers = List.from(players);
    if (players.length >= 3 && _lastPlayerId != null) {
      availablePlayers.removeWhere((p) => p.id == _lastPlayerId);
    }

    _currentPlayer = availablePlayers[_random.nextInt(availablePlayers.length)];
    _lastPlayerId = _currentPlayer?.id;
    _state = 'choosing_type';
    notifyListeners();
  }

  void chooseType(GameContent content) {
    _currentContent = content;
    _state = 'playing';
    notifyListeners();
  }

  void completeTurn() {
    _state = 'result';
    notifyListeners();
  }

  void nextTurn() {
    _currentContent = null;
    _state = 'selecting_player';
    notifyListeners();
  }
}
