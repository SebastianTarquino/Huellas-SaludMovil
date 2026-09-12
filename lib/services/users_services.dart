import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/users.dart';

class UserService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.internalBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<List<User>> fetchUsers({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get(
        'user/list-users',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data;

        // Mapear solo los datos que vienen en results sin hacer peticiones extra
        final List<User> users = results.map((item) {
          final data = item['data'] ?? {};

          return User(
            name: data['name'],
            lastName: data['lastName'],
            role: data['role'],
            documentNumber: data['documentNumber']
          );
        }).toList();

        return users;
      } else {
        throw Exception('Failed to load users');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<User> fetchUserById(int id) async {
    try {
      final response = await _dio.get('user/$id'); // 👈 Ajusta el endpoint

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to load user');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<bool> registerUser({
    required String name,
    required String lastName,
    required String email,
    required String documentNumber,
    required String password,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await _dio.post(
        'user/create',
        data: {
          'data': {
            'name': name,
            'lastName': lastName,
            'email': email,
            'documentNumber': documentNumber,
            'password': password,
            'phone': phone,
            'address': address,
            'role': 'CLIENTE',
          }
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      String msg = 'Error al registrar usuario';
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          msg = data['message'];
        }
      }
      throw Exception(msg);
    }
  }

}
