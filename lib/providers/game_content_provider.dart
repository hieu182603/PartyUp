import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/game_content.dart';
import '../services/database_helper.dart';

class GameContentProvider with ChangeNotifier {
  List<GameContent> _truths = [];
  List<GameContent> _dares = [];
  List<GameContent> _rules = [];
  List<GameContent> _favorites = [];

  List<GameContent> get truths => _truths;
  List<GameContent> get dares => _dares;
  List<GameContent> get rules => _rules;
  List<GameContent> get favorites => _favorites;

  final Random _random = Random();
  final Set<int> _usedContentIds = {};

  void resetUsedContents() {
    _usedContentIds.clear();
    notifyListeners();
  }

  Future<void> loadContents() async {
    _truths = await DatabaseHelper.instance.getContentsByType('truth');
    _dares = await DatabaseHelper.instance.getContentsByType('dare');
    _rules = await DatabaseHelper.instance.getContentsByType('rule');
    _favorites = await DatabaseHelper.instance.getFavoriteContents();
    notifyListeners();
  }

  int getCategoryCount(String category) {
    if (_truths.isEmpty && _dares.isEmpty) return 0; // Not loaded yet
    
    if (category == 'Tổng hợp') {
      return _truths.length + _dares.length + _rules.length;
    }
    
    int count = 0;
    count += _truths.where((c) => c.category == category).length;
    count += _dares.where((c) => c.category == category).length;
    count += _rules.where((c) => c.category == category).length;
    return count;
  }

  Future<GameContent?> getRandomContent(String type, {List<String>? categories, String? difficulty, bool favoritesOnly = false}) async {
    // Chỉ load lại nếu kho đang trống hoàn toàn, hoặc loại đang cần bị rỗng
    if (_truths.isEmpty && _dares.isEmpty && _rules.isEmpty) {
      await loadContents();
    } else if (type == 'truth' && _truths.isEmpty) {
      await loadContents();
    } else if (type == 'dare' && _dares.isEmpty) {
      await loadContents();
    } else if (type == 'rule' && _rules.isEmpty) {
      await loadContents();
    }

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

    if (favoritesOnly) {
      list = list.where((c) => c.isFavorite).toList();
    }

    if (categories != null && categories.isNotEmpty && !categories.contains('Tất cả') && !categories.contains('Tổng hợp')) {
      list = list.where((c) => categories.contains(c.category)).toList();
    }
    
    if (difficulty != null) {
      list = list.where((c) => c.level == difficulty).toList();
    }

    if (list.isEmpty) return null;

    // Filter out used contents
    List<GameContent> availableList = list.where((c) => c.id != null && !_usedContentIds.contains(c.id)).toList();

    if (availableList.isEmpty) {
      return null; // Indicates depletion
    }

    final selected = availableList[_random.nextInt(availableList.length)];
    _usedContentIds.add(selected.id!);
    return selected;
  }

  Future<void> toggleFavorite(GameContent content) async {
    if (content.id == null) return;
    
    final newFavoriteState = !content.isFavorite;
    await DatabaseHelper.instance.toggleFavoriteGameContent(content.id!, newFavoriteState);
    await loadContents(); // Reload to reflect changes across all lists
  }
}
