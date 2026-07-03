import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/game_content.dart';
import '../services/database_helper.dart';

class GameContentProvider with ChangeNotifier {
  List<GameContent> _truths = [];
  List<GameContent> _dares = [];
  List<GameContent> _rules = [];

  List<GameContent> get truths => _truths;
  List<GameContent> get dares => _dares;
  List<GameContent> get rules => _rules;

  final Random _random = Random();

  Future<void> loadContents() async {
    _truths = await DatabaseHelper.instance.getContentsByType('truth');
    _dares = await DatabaseHelper.instance.getContentsByType('dare');
    _rules = await DatabaseHelper.instance.getContentsByType('rule');
    notifyListeners();
  }

  GameContent? getRandomContent(String type) {
    List<GameContent> list;
    switch (type) {
      case 'truth':
        list = _truths;
        break;
      case 'dare':
        list = _dares;
        break;
      case 'rule':
        list = _rules;
        break;
      default:
        return null;
    }

    if (list.isEmpty) return null;
    return list[_random.nextInt(list.length)];
  }
}
