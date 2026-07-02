import 'package:dio/dio.dart';
import 'package:flutter_mvvm/core/constants/api_constants.dart';

class ApiClient {
  ApiClient._();
  static Dio createDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }
}
