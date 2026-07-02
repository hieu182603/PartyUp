import 'package:flutter_mvvm/features/data/dtos/app_user_dto.dart';
import 'package:flutter_mvvm/features/data/mappers/interfaces/i_mapper.dart';
import 'package:flutter_mvvm/features/domain/entities/app_user.dart';

class UserMapper implements IMapper<AppUserDto, AppUser> {
  @override
  AppUser map(AppUserDto source) {
    final addressPart = source.address.address;
    final cityPart = source.address.city;
    final fullAddress = addressPart.isNotEmpty
        ? (cityPart.isNotEmpty ? '$addressPart, $cityPart' : addressPart)
        : cityPart;

    return AppUser(
      id: source.id.toString(),
      firstName: source.firstName,
      lastName: source.lastName,
      username: source.username,
      email: source.email,
      phone: source.phone,
      age: source.age,
      gender: source.gender,
      birthDate: source.birthDate,
      address: fullAddress,
      imageUrl: source.imageUrl,
    );
  }

  AppUserDto mapToDto(AppUser source) {
    final parts = source.address.split(',');
    final addressText = parts.isNotEmpty ? parts.first.trim() : '';
    final cityText = parts.length > 1 ? parts.sublist(1).join(',').trim() : '';

    return AppUserDto(
      id: int.tryParse(source.id) ?? 0,
      firstName: source.firstName,
      lastName: source.lastName,
      username: source.username,
      email: source.email,
      phone: source.phone,
      age: source.age,
      gender: source.gender,
      birthDate: source.birthDate,
      address: AppAddressDto(address: addressText, city: cityText),
      imageUrl: source.imageUrl,
    );
  }
}
