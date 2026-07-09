import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/secret_rule.dart';
import '../models/player.dart';
class SecretRuleProvider with ChangeNotifier {
  // Game Configuration
  int totalRounds = 5;
  int timePerRound = 180; // in seconds
  String selectedLevel = 'Nhẹ';
  bool allowChangeRule = true;
  bool allowCancelViolation = true;
  bool soundEnabled = true;
  bool stackingRules = true;

  // State
  int currentRound = 1;
  int timeLeft = 180;
  bool isTimerRunning = false;
  Timer? _timer;

  // Turn tracking
  List<Player> players = [];
  int currentPlayerIndex = 0;
  int? currentSessionId;

  // Rules Data
  List<SecretRule> _allRules = [];
  List<SecretRule> activeRules = [];
  int changeRuleChances = 1; // 1 reroll per game? Or per round? Let's say per game as in Truth Or Dare.

  // Violations Tracking: Player ID -> Number of violations
  Map<int, int> violations = {};

  final Random _random = Random();

  // Reset for a new game
  void reset() {
    currentRound = 1;
    currentPlayerIndex = 0;
    activeRules.clear();
    violations.clear();
    changeRuleChances = 1;
    stopTimer();
    notifyListeners();
  }

  void configureGame({
    required int rounds,
    required int time,
    required String level,
    required bool allowChange,
    required bool allowCancel,
    required bool sound,
    required bool stacking,
  }) {
    totalRounds = rounds;
    timePerRound = time;
    selectedLevel = level;
    allowChangeRule = allowChange;
    allowCancelViolation = allowCancel;
    soundEnabled = sound;
    stackingRules = stacking;
    
    changeRuleChances = allowChange ? 1 : 0;
    notifyListeners();
  }

  void setPlayers(List<Player> newPlayers) {
    players = newPlayers;
  }

  Future<void> loadRules() async {
    try {
      final String response = await rootBundle.loadString('assets/data/secret_rules.json');
      final List<dynamic> data = json.decode(response);
      _allRules = data.map((json) => SecretRule.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading secret rules: $e');
    }
  }

  void startRound() {
    currentPlayerIndex = 0;
    if (_allRules.isEmpty) return;

    // Filter rules by level
    final levelRules = _allRules.where((r) => r.level == selectedLevel).toList();
    if (levelRules.isEmpty) return;

    // Pick a new rule that isn't already active
    final availableRules = levelRules.where((r) => !activeRules.contains(r)).toList();
    if (availableRules.isNotEmpty) {
      final newRule = availableRules[_random.nextInt(availableRules.length)];
      if (!stackingRules) {
        activeRules.clear();
      }
      activeRules.add(newRule);
    }

    timeLeft = timePerRound;
    startTimer();
    notifyListeners();
  }

  void changeCurrentRule() {
    if (changeRuleChances <= 0 || activeRules.isEmpty) return;
    
    final levelRules = _allRules.where((r) => r.level == selectedLevel).toList();
    final availableRules = levelRules.where((r) => !activeRules.contains(r)).toList();
    
    if (availableRules.isNotEmpty) {
      final newRule = availableRules[_random.nextInt(availableRules.length)];
      activeRules.last = newRule; // Replace the most recently added rule
      changeRuleChances--;
      notifyListeners();
    }
  }

  void startTimer() {
    if (isTimerRunning) return;
    isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        timeLeft--;
        notifyListeners();
      } else {
        stopTimer();
        // Trigger end of round callback if needed, or UI can listen to timeLeft == 0
      }
    });
    notifyListeners();
  }

  void pauseTimer() {
    if (!isTimerRunning) return;
    isTimerRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void stopTimer() {
    isTimerRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void resumeTimer() {
    if (timeLeft > 0) {
      startTimer();
    }
  }

  void addViolation(int playerId) {
    violations[playerId] = (violations[playerId] ?? 0) + 1;
    notifyListeners();
  }

  void removeViolation(int playerId) {
    if (allowCancelViolation && violations.containsKey(playerId) && violations[playerId]! > 0) {
      violations[playerId] = violations[playerId]! - 1;
      notifyListeners();
    }
  }

  void nextRound() {
    if (currentRound < totalRounds) {
      currentRound++;
      startRound();
    }
  }

  void nextTurn() {
    if (players.isEmpty) return;
    
    stopTimer();
    
    if (currentPlayerIndex < players.length - 1) {
      currentPlayerIndex++;
      timeLeft = timePerRound;
      startTimer();
      notifyListeners();
    } else {
      if (currentRound < totalRounds) {
        nextRound();
      } else {
        timeLeft = 0;
        notifyListeners();
      }
    }
  }

  bool get isGameOver => currentRound >= totalRounds && timeLeft == 0 && currentPlayerIndex >= players.length - 1;
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
