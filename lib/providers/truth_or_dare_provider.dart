import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/player.dart';
import '../models/game_content.dart';
import '../services/database_helper.dart';

class TruthOrDareProvider with ChangeNotifier {
  // ─── State machine ───────────────────────────────────────────────────────
  // States: 'selecting_player' | 'choosing_type' | 'playing' | 'result'
  String _state = 'selecting_player';
  String get state => _state;

  // ─── Current turn data ────────────────────────────────────────────────────
  Player? _currentPlayer;
  GameContent? _currentContent;
  Player? get currentPlayer => _currentPlayer;
  GameContent? get currentContent => _currentContent;

  // ─── Session ─────────────────────────────────────────────────────────────
  int? currentSessionId;
  List<String> currentCategories = ['Tổng hợp'];
  String? currentDifficulty;
  bool favoritesOnly = false;

  // ─── Game configuration ───────────────────────────────────────────────────
  int totalRounds = 5;
  int currentRound = 1;
  int timeLimit = 30; // seconds
  int rewardPoints = 20;
  int penaltyPoints = -10;

  // ─── Round tracking ───────────────────────────────────────────────────────
  final Set<int> _playedThisRound = {};
  
  // Lịch sử người chơi đã đổi câu hỏi trong toàn bộ ván
  final Set<int> _hasRerolled = {};

  // Round-level stats (reset each round)
  int correctCount = 0;
  int skipCount = 0;
  int pointsGainedThisRound = 0; // net points awarded this round

  // Expose counts for UI
  int get playedThisRound => _playedThisRound.length;
  // Backwards-compat alias used in old code
  int get pointsGained => pointsGainedThisRound;
  int get turnInRound => _playedThisRound.length;

  final Random _random = Random();

  // ─── Reset ────────────────────────────────────────────────────────────────
  void reset() {
    _state = 'selecting_player';
    _currentPlayer = null;
    _currentContent = null;
    currentSessionId = null;
    currentRound = 1;
    currentCategories = ['Tổng hợp'];
    currentDifficulty = null;
    _playedThisRound.clear();
    correctCount = 0;
    skipCount = 0;
    pointsGainedThisRound = 0;
    notifyListeners();
  }

  // ─── Configure ────────────────────────────────────────────────────────────
  void configureGame({
    required int rounds,
    required int time,
    required int reward,
    required int penalty,
    List<String>? categories,
    String? difficulty,
    bool favoritesOnly = false,
  }) {
    totalRounds = rounds;
    timeLimit = time;
    rewardPoints = reward;
    penaltyPoints = penalty;
    currentDifficulty = difficulty;
    this.favoritesOnly = favoritesOnly;
    _hasRerolled.clear();
    if (categories != null && categories.isNotEmpty) {
      currentCategories = categories;
    }
    notifyListeners();
  }

  // ─── Select a player who hasn't played this round yet ────────────────────
  // Returns true if a player was selected, false if round is already complete.
  bool selectRandomPlayer(List<Player> players) {
    if (players.isEmpty) return false;

    // Filter: only players who have NOT played this round
    final available = players
        .where((p) => p.id != null && !_playedThisRound.contains(p.id))
        .toList();

    if (available.isEmpty) {
      // Everyone played → the round should have ended already.
      // Safety: treat as round complete.
      return false;
    }

    _currentPlayer = available[_random.nextInt(available.length)];
    _state = 'choosing_type';
    notifyListeners();
    return true;
  }

  // ─── Choose content ───────────────────────────────────────────────────────
  void chooseType(GameContent content) {
    _currentContent = content;
    _state = 'playing';
    notifyListeners();
  }

  // ─── Record outcome ───────────────────────────────────────────────────────
  void recordAnswer(int points) {
    if (_currentPlayer?.id != null) {
      _playedThisRound.add(_currentPlayer!.id!);
    }
    
    if (currentSessionId != null && _currentPlayer != null && _currentContent != null) {
      DatabaseHelper.instance.insertSessionTurn(
        currentSessionId!,
        currentRound,
        _currentPlayer!.name,
        _currentContent!.content,
        points,
      );
    }

    correctCount++;
    pointsGainedThisRound += points;
    _currentContent = null;
    notifyListeners();
  }

  bool canReroll(int playerId) {
    return !_hasRerolled.contains(playerId);
  }

  void useReroll(int playerId) {
    _hasRerolled.add(playerId);
    notifyListeners();
  }

  void recordSkip(int points) {
    if (_currentPlayer?.id != null) {
      _playedThisRound.add(_currentPlayer!.id!);
    }
    
    if (currentSessionId != null && _currentPlayer != null && _currentContent != null) {
      DatabaseHelper.instance.insertSessionTurn(
        currentSessionId!,
        currentRound,
        _currentPlayer!.name,
        _currentContent!.content,
        points, // negative value
      );
    }

    skipCount++;
    pointsGainedThisRound += points; // points is negative for penalty
    _currentContent = null;
    notifyListeners();
  }

  // ─── Round complete check ─────────────────────────────────────────────────
  bool isRoundComplete(int totalPlayers) {
    return totalPlayers > 0 && _playedThisRound.length >= totalPlayers;
  }

  bool get isGameOver => currentRound >= totalRounds;

  // ─── Advance to next round ────────────────────────────────────────────────
  void nextRound() {
    currentRound++;
    _playedThisRound.clear();
    _hasRerolled.clear(); // Đặt lại quyền đổi câu cho mỗi vòng mới
    correctCount = 0;
    skipCount = 0;
    pointsGainedThisRound = 0;
    _currentPlayer = null;
    _currentContent = null;
    _state = 'selecting_player';
    notifyListeners();
  }

  // ─── Advance to next round / turn ─────────────────────────────────────────
  void completeTurn(bool roundComplete) {
    _state = roundComplete ? 'result' : 'selecting_player';
    notifyListeners();
  }

  void nextTurn() {
    _currentContent = null;
    _state = 'selecting_player';
    notifyListeners();
  }

  // ─── Restore Session ──────────────────────────────────────────────────────
  void restoreSession(int sessionId, int round, Set<int> playedIds) {
    currentSessionId = sessionId;
    currentRound = round;
    _playedThisRound.clear();
    _playedThisRound.addAll(playedIds);
    
    // Reset turn-specific state
    _currentPlayer = null;
    _currentContent = null;
    _state = 'selecting_player';
    
    // Reset round stats (these would be partial since we don't have full history, but we start fresh for the rest of the round)
    correctCount = 0;
    skipCount = 0;
    pointsGainedThisRound = 0;
    
    notifyListeners();
  }
}
