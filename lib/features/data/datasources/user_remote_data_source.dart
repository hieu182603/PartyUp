import 'package:dio/dio.dart';
import 'package:flutter_mvvm/core/erros/app_exception.dart';
import 'package:flutter_mvvm/features/data/dtos/app_user_dto.dart';
import 'package:flutter_mvvm/features/data/dtos/user_list_response_dto.dart';

class UserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSource(this._dio);

  Future<UserListResponseDto> getUsers({int limit = 10, int skip = 0}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users',
        queryParameters: {'limit': limit, 'skip': skip},
      );
      final data = response.data;
      if (data != null) {
        return UserListResponseDto.fromJson(data);
      } else {
        throw AppException('Không nhận được dữ liệu từ API');
      }
    } on DioException catch (error) {
      throw AppException(_getErrorMessage(error));
    }
  }

  Future<UserListResponseDto> searchUsers(String query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/search',
        queryParameters: {'q': query},
      );
      final data = response.data;
      if (data != null) {
        return UserListResponseDto.fromJson(data);
      } else {
        throw AppException('Không nhận được dữ liệu từ API');
      }
    } on DioException catch (error) {
      throw AppException(_getErrorMessage(error));
    }
  }

  Future<AppUserDto> getUserDetail(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/users/$id');
      final data = response.data;
      if (data != null) {
        return AppUserDto.fromJson(data);
      } else {
        throw AppException('Không nhận được dữ liệu từ API');
      }
    } on DioException catch (error) {
      throw AppException(_getErrorMessage(error));
    }
  }

  Future<AppUserDto> createUser(AppUserDto user) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/users/add',
        data: user.toJson(),
      );
      final data = response.data;
      if (data != null) {
        return AppUserDto.fromJson(data);
      } else {
        throw AppException('Không tạo được người dùng');
      }
    } on DioException catch (error) {
      throw AppException(_getErrorMessage(error));
    }
  }

  Future<AppUserDto> updateUser(String id, AppUserDto user) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/users/$id',
        data: user.toJson(),
      );
      final data = response.data;
      if (data != null) {
        return AppUserDto.fromJson(data);
      } else {
        throw AppException('Không cập nhật được người dùng');
      }
    } on DioException catch (error) {
      throw AppException(_getErrorMessage(error));
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _dio.delete<Map<String, dynamic>>('/users/$id');
    } on DioException catch (error) {
      throw AppException(_getErrorMessage(error));
    }
  }
}

String _getErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message'];
    if (message != null) {
      return message.toString();
    }
  }
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    return 'Kết nối mạng quá hạn. Vui lòng thử lại sau.';
  }
  if (error.type == DioExceptionType.connectionError) {
    return 'Lỗi kết nối tới máy chủ. Vui lòng kiểm tra lại mạng.';
  }

  return 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại sau.';
}
