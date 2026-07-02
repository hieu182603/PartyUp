
import 'package:flutter_mvvm/features/data/dtos/login_respone.dto.dart';
import 'package:flutter_mvvm/features/data/mappers/interfaces/i_mapper.dart';
import 'package:flutter_mvvm/features/domain/entities/user.dart';

class UserMapper implements IMapper<LoginResponseDto, User> {
  @override
  User map(LoginResponseDto source) {
    return User(
      id: source.user.id.toString(),
      username: source.user.username,
      email: source.user.email,
      fullName: '${source.user.firstName} ${source.user.lastName}'.trim(),
      imageUrl: source.user.imageUrl,
      accessToken: source.accessToken,
      refreshToken: source.refreshToken,
    );
  }
}
