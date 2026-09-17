import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/users.dart';

class UserService {
  static const String _customUsersKey = 'user_custom_users_list';
  static const String _deletedDocsKey = 'user_deleted_documents_set';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.internalBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // 🔍 Obtener conjunto de documentos eliminados
  Future<Set<String>> getDeletedDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deletedList = prefs.getStringList(_deletedDocsKey) ?? [];
      return deletedList.toSet();
    } catch (e) {
      return {};
    }
  }

  // 🗑️ Eliminar usuario y recordarlo en la lista de eliminados
  Future<void> deleteUser(String documentNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Agregar a la lista de documentos eliminados
      final deletedList = prefs.getStringList(_deletedDocsKey) ?? [];
      if (!deletedList.contains(documentNumber)) {
        deletedList.add(documentNumber);
        await prefs.setStringList(_deletedDocsKey, deletedList);
      }

      // 2. Remover de los usuarios personalizados locales
      final customUsers = await getCustomUsers();
      customUsers.removeWhere((u) => u.documentNumber == documentNumber);
      await saveCustomUsers(customUsers);

      // 3. Notificar al backend en caso de tener endpoint activo
      await _dio.delete(
        'user/$documentNumber',
        options: Options(validateStatus: (status) => true),
      );
    } catch (e) {
      print("Error al eliminar usuario: $e");
    }
  }

  // 💾 Cargar usuarios guardados localmente (excluyendo eliminados)
  Future<List<User>> getCustomUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deletedDocs = await getDeletedDocuments();
      final str = prefs.getString(_customUsersKey);
      if (str != null && str.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(str);
        final list = jsonList
            .map((item) => User.fromJson(Map<String, dynamic>.from(item)))
            .where((u) => !deletedDocs.contains(u.documentNumber))
            .toList();
        return list;
      }
    } catch (e) {
      print("Error al cargar usuarios locales: $e");
    }
    return [];
  }

  // 💾 Guardar lista completa de usuarios localmente
  Future<void> saveCustomUsers(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(users.map((u) => u.toJson()).toList());
      await prefs.setString(_customUsersKey, jsonString);
    } catch (e) {
      print("Error al guardar usuarios locales: $e");
    }
  }

  // 🌐 Obtener usuarios del backend + locales con fotos vinculadas (excluyendo eliminados)
  Future<List<User>> fetchUsers({int limit = 20, int offset = 0}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deletedDocs = await getDeletedDocuments();
      final customUsers = await getCustomUsers();

      final response = await _dio.get(
        'user/list-users',
        queryParameters: {'limit': limit, 'offset': offset},
        options: Options(validateStatus: (status) => true),
      );

      final List<User> backendUsers = [];
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> results = response.data;
        for (var item in results) {
          final data = item['data'] ?? {};
          final docNum = (data['documentNumber'] ?? '').toString();

          if (deletedDocs.contains(docNum)) continue;

          final email = (data['email'] ?? '').toString();

          String? avatar;
          final storageKey = email.isNotEmpty ? email : docNum;
          if (storageKey.isNotEmpty) {
            avatar = prefs.getString('user_profile_avatar_$storageKey');
          }

          backendUsers.add(User(
            name: data['name'] ?? '',
            lastName: data['lastName'] ?? '',
            role: (data['role'] ?? 'CLIENTE').toString().toUpperCase().trim(),
            documentNumber: docNum,
            email: email,
            phone: data['phone'],
            address: data['address'],
            avatarBase64: avatar ?? data['avatarBase64'],
            isActive: data['isActive'] ?? true,
          ));
        }
      }

      final Map<String, User> userMap = {};

      for (var u in customUsers) {
        if (u.documentNumber.isNotEmpty && !deletedDocs.contains(u.documentNumber)) {
          userMap[u.documentNumber] = u;
        }
      }

      for (var u in backendUsers) {
        if (u.documentNumber.isNotEmpty &&
            !deletedDocs.contains(u.documentNumber) &&
            !userMap.containsKey(u.documentNumber)) {
          userMap[u.documentNumber] = u;
        }
      }

      return userMap.values.toList();
    } catch (e) {
      print("Error al obtener usuarios: $e");
      return await getCustomUsers();
    }
  }

  Future<User> fetchUserById(int id) async {
    try {
      final response = await _dio.get('user/$id');

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
    String role = 'CLIENTE',
    String? avatarBase64,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deletedList = prefs.getStringList(_deletedDocsKey) ?? [];
      if (deletedList.contains(documentNumber)) {
        deletedList.remove(documentNumber);
        await prefs.setStringList(_deletedDocsKey, deletedList);
      }

      if (avatarBase64 != null && avatarBase64.isNotEmpty) {
        final key = email.isNotEmpty ? email : documentNumber;
        await prefs.setString('user_profile_avatar_$key', avatarBase64);
      }

      final newUser = User(
        name: name,
        lastName: lastName,
        role: role.toUpperCase().trim(),
        documentNumber: documentNumber,
        email: email,
        phone: phone,
        address: address,
        avatarBase64: avatarBase64,
        isActive: true,
      );

      final customUsers = await getCustomUsers();
      customUsers.removeWhere((u) => u.documentNumber == documentNumber);
      customUsers.insert(0, newUser);
      await saveCustomUsers(customUsers);

      await _dio.post(
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
            'role': role,
          }
        },
        options: Options(validateStatus: (status) => true),
      );

      return true;
    } catch (e) {
      print("Error al registrar usuario: $e");
      return true;
    }
  }
}
