import 'package:flutter/material.dart';
import 'package:flutter_mvvm/core/erros/app_exception.dart';
import 'package:flutter_mvvm/features/application/service/interfaces/i_user_service.dart';
import 'package:flutter_mvvm/features/domain/entities/app_user.dart';

enum UserListState { initial, loading, success, failure }

class UserListViewModel extends ChangeNotifier {
  final IUserService _userService;

  UserListViewModel(this._userService);

  UserListState _state = UserListState.initial;
  String? _errorMessage;
  List<AppUser> _users = [];
  int _totalUsers = 0;
  int _currentPage = 1;
  final int _limit = 10;
  String _searchQuery = '';

  UserListState get state => _state;
  String? get errorMessage => _errorMessage;
  List<AppUser> get users => _users;
  int get totalUsers => _totalUsers;
  int get currentPage => _currentPage;
  int get totalPages => (_totalUsers / _limit).ceil();
  bool get isLoading => _state == UserListState.loading;
  String get searchQuery => _searchQuery;

  Future<void> fetchUsers({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
    }
    _state = UserListState.loading;
    notifyListeners();

    try {
      final skip = (_currentPage - 1) * _limit;
      if (_searchQuery.isNotEmpty) {
        final results = await _userService.searchUsers(_searchQuery);
        _users = results;
        _totalUsers = results.length;
      } else {
        final results = await _userService.getUsers(limit: _limit, skip: skip);
        _users = results;
        // API DummyJSON mặc định có tổng cộng 208 users (hoặc 100 tùy phiên bản).
        // Đặt mặc định 100 để hiển thị phân trang đẹp mắt.
        _totalUsers = 100;
      }
      _state = UserListState.success;
      _errorMessage = null;
      notifyListeners();
    } on AppException catch (e) {
      _state = UserListState.failure;
      _errorMessage = e.message;
      notifyListeners();
    } catch (_) {
      _state = UserListState.failure;
      _errorMessage = 'Đã xảy ra lỗi không xác định khi tải danh sách';
      notifyListeners();
    }
  }

  Future<void> searchUsers(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await fetchUsers();
  }

  Future<void> changePage(int page) async {
    if (page < 1 || (totalPages > 0 && page > totalPages)) return;
    _currentPage = page;
    await fetchUsers();
  }

  void updateUserLocally(AppUser updatedUser) {
    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
    }
  }

  void addUserLocally(AppUser newUser) {
    _users.insert(0, newUser);
    _totalUsers++;
    notifyListeners();
  }

  Future<bool> deleteUser(String id) async {
    try {
      await _userService.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      _totalUsers = _totalUsers > 0 ? _totalUsers - 1 : 0;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Đã xảy ra lỗi không xác định khi xóa';
      notifyListeners();
      return false;
    }
  }
}
