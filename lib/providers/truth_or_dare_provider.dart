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

  // Game configuration
  int totalRounds = 5;
  int currentRound = 1;
  int timeLimit = 30; // seconds
  int rewardPoints = 20;
  int penaltyPoints = -10;

  // Round stats
  int correctCount = 0;
  int skipCount = 0;
  int pointsGained = 0;
  int turnInRound = 0;

  void reset() {
    _currentPlayer = null;
    _currentContent = null;
    _state = 'selecting_player';
    _lastPlayerId = null;
    currentRound = 1;
    turnInRound = 0;
    correctCount = 0;
    skipCount = 0;
    pointsGained = 0;
    notifyListeners();
  }

  void configureGame({
    required int rounds,
    required int time,
    required int reward,
    required int penalty,
  }) {
    totalRounds = rounds;
    timeLimit = time;
    rewardPoints = reward;
    penaltyPoints = penalty;
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

  void recordAnswer(int points) {
    correctCount++;
    pointsGained += points;
    turnInRound++;
    notifyListeners();
  }

  void recordSkip(int points) {
    skipCount++;
    pointsGained += points;
    turnInRound++;
    notifyListeners();
  }

  void nextRound() {
    currentRound++;
    turnInRound = 0;
    correctCount = 0;
    skipCount = 0;
    pointsGained = 0;
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
