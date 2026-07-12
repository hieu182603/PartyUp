import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../services/database_helper.dart';

class PlayerProvider with ChangeNotifier {
  List<Player> _players = [];
  
  List<Player> get players => _players;

  Future<void> loadPlayersForGroup(int groupId) async {
    _players = await DatabaseHelper.instance.getPlayersByGroup(groupId);
    notifyListeners();
  }

  void clearPlayers() {
    _players.clear();
    notifyListeners();
  }

  Future<void> addPlayer(int groupId, String name, {String? avatar}) async {
    final player = Player(groupId: groupId, name: name, avatar: avatar);
    final id = await DatabaseHelper.instance.createPlayer(player);
    await DatabaseHelper.instance.createGlobalPlayer(name);
    _players.add(player.copyWith(id: id));
    notifyListeners();
  }

  Future<void> removePlayer(int id) async {
    await DatabaseHelper.instance.deletePlayer(id);
    _players.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> updatePlayerScore(int id, int points) async {
    final index = _players.indexWhere((p) => p.id == id);
    if (index != -1) {
      _players[index].score += points;
      await DatabaseHelper.instance.updatePlayer(_players[index]);
      await DatabaseHelper.instance.addPointsToGlobalPlayer(_players[index].name, points, 0);
      notifyListeners();
    }
  }

  Future<void> updatePlayerPenalty(int id, int penaltyPoints) async {
    final index = _players.indexWhere((p) => p.id == id);
    if (index != -1) {
      _players[index].penalty += penaltyPoints;
      await DatabaseHelper.instance.updatePlayer(_players[index]);
      await DatabaseHelper.instance.addPointsToGlobalPlayer(_players[index].name, 0, penaltyPoints);
      notifyListeners();
    }
  }

  Future<void> resetScores() async {
    for (int i = 0; i < _players.length; i++) {
      _players[i].score = 0;
      _players[i].penalty = 0;
      await DatabaseHelper.instance.updatePlayer(_players[i]);
    }
    notifyListeners();
  }

  Future<void> restoreSessionScoresAndPenalties(Map<String, int> scores, Map<String, int> penalties) async {
    for (int i = 0; i < _players.length; i++) {
      final name = _players[i].name;
      _players[i].score = scores[name] ?? 0;
      _players[i].penalty = penalties[name] ?? 0;
      await DatabaseHelper.instance.updatePlayer(_players[i]);
    }
    notifyListeners();
  }
}
