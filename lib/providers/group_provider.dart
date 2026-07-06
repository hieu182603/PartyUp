import 'package:flutter/foundation.dart';
import '../models/player_group.dart';
import '../services/database_helper.dart';

class GroupProvider with ChangeNotifier {
  List<PlayerGroup> _groups = [];
  PlayerGroup? _currentGroup;

  List<PlayerGroup> get groups => _groups;
  PlayerGroup? get currentGroup => _currentGroup;

  Future<void> loadGroups() async {
    _groups = await DatabaseHelper.instance.getGroups();
    notifyListeners();
  }

  Future<void> createGroup(String name) async {
    final group = PlayerGroup(name: name);
    final id = await DatabaseHelper.instance.createGroup(group);
    
    // Tạo group với ID vừa nhận được
    final newGroup = PlayerGroup(id: id, name: name, createdAt: group.createdAt);
    _groups.insert(0, newGroup);
    setCurrentGroup(newGroup);
    notifyListeners();
  }

  Future<void> updateGroupName(int id, String newName) async {
    final index = _groups.indexWhere((g) => g.id == id);
    if (index != -1) {
      final updatedGroup = PlayerGroup(id: id, name: newName, createdAt: _groups[index].createdAt);
      _groups[index] = updatedGroup;
      if (_currentGroup?.id == id) {
        _currentGroup = updatedGroup;
      }
      await DatabaseHelper.instance.updateGroup(updatedGroup);
      notifyListeners();
    }
  }

  void setCurrentGroup(PlayerGroup group) {
    _currentGroup = group;
    notifyListeners();
  }

  void clearCurrentGroup() {
    _currentGroup = null;
    notifyListeners();
  }

  Future<void> deleteGroup(int id) async {
    await DatabaseHelper.instance.deleteGroup(id);
    _groups.removeWhere((g) => g.id == id);
    if (_currentGroup?.id == id) {
      _currentGroup = null;
    }
    notifyListeners();
  }
}
