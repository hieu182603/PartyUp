import 'package:flutter_mvvm/features/domain/entities/app_user.dart';

abstract interface class IUserRepository {
  Future<List<AppUser>> getUsers({int limit = 10, int skip = 0});
  Future<List<AppUser>> searchUsers(String query);
  Future<AppUser> getUserDetail(String id);
  Future<AppUser> createUser(AppUser user);
  Future<AppUser> updateUser(String id, AppUser user);
  Future<void> deleteUser(String id);
}
