import 'package:flutter_mvvm/core/erros/app_exception.dart';
import 'package:flutter_mvvm/features/application/service/interfaces/i_user_service.dart';
import 'package:flutter_mvvm/features/domain/entities/app_user.dart';
import 'package:flutter_mvvm/features/domain/repositories/i_user_repository.dart';

class UserServiceImpl implements IUserService {
  final IUserRepository _userRepository;

  UserServiceImpl(this._userRepository);

  @override
  Future<List<AppUser>> getUsers({int limit = 10, int skip = 0}) async {
    return await _userRepository.getUsers(limit: limit, skip: skip);
  }

  @override
  Future<List<AppUser>> searchUsers(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return await _userRepository.getUsers(limit: 10, skip: 0);
    }
    return await _userRepository.searchUsers(trimmedQuery);
  }

  @override
  Future<AppUser> getUserDetail(String id) async {
    if (id.isEmpty) {
      throw AppException('ID người dùng không được để trống');
    }
    return await _userRepository.getUserDetail(id);
  }

  @override
  Future<AppUser> createUser(AppUser user) async {
    _validateUser(user);
    return await _userRepository.createUser(user);
  }

  @override
  Future<AppUser> updateUser(String id, AppUser user) async {
    if (id.isEmpty) {
      throw AppException('ID người dùng không được để trống');
    }
    _validateUser(user);
    return await _userRepository.updateUser(id, user);
  }

  @override
  Future<void> deleteUser(String id) async {
    if (id.isEmpty) {
      throw AppException('ID người dùng không được để trống');
    }
    await _userRepository.deleteUser(id);
  }

  void _validateUser(AppUser user) {
    if (user.firstName.trim().isEmpty) {
      throw AppException('Họ không được để trống');
    }
    if (user.lastName.trim().isEmpty) {
      throw AppException('Tên không được để trống');
    }
    if (user.username.trim().isEmpty) {
      throw AppException('Username không được để trống');
    }
    if (user.email.trim().isEmpty) {
      throw AppException('Email không được để trống');
    }
    if (!user.email.contains('@')) {
      throw AppException('Email không đúng định dạng');
    }
    if (user.phone.trim().isEmpty) {
      throw AppException('Số điện thoại không được để trống');
    }
  }
}
