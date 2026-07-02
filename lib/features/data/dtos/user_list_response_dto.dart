import 'package:flutter_mvvm/features/data/dtos/app_user_dto.dart';

class UserListResponseDto {
  final List<AppUserDto> users;
  final int total;
  final int skip;
  final int limit;

  const UserListResponseDto({
    required this.users,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory UserListResponseDto.fromJson(Map<String, dynamic> json) {
    final list = json['users'] as List? ?? [];
    return UserListResponseDto(
      users: list.map((e) => AppUserDto.fromJson(e as Map<String, dynamic>)).toList(),
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }
}
