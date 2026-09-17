// ...existing code...
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// ...existing code...

class AuthService {
  final String baseUrl;
  AuthService({required this.baseUrl});

  static final List<Map<String, dynamic>> _demoUsers = [
    {
      'name': 'Armando',
      'lastName': 'Puentes',
      'role': 'ADMIN',
      'documentNumber': '10987654321',
      'email': 'armando@demo.com',
      'phone': '+57 300 123 4567',
      'address': 'Calle 100 #15-20',
      'isActive': true,
    },
    {
      'name': 'Valeria',
      'lastName': 'Gómez',
      'role': 'VETERINARIO',
      'documentNumber': '10987654322',
      'email': 'valeria@demo.com',
      'phone': '+57 310 987 6543',
      'address': 'Carrera 45 #30-10',
      'isActive': true,
    },
    {
      'name': 'Sebastian',
      'lastName': 'Tarquino',
      'role': 'CLIENTE',
      'documentNumber': '10987654323',
      'email': 'sebastian@demo.com',
      'phone': '+57 320 456 7890',
      'address': 'Transversal 14P #60-17',
      'isActive': true,
    },
    {
      'name': 'Clara',
      'lastName': 'Heredia',
      'role': 'CLIENTE',
      'documentNumber': '10987654324',
      'email': 'clara@demo.com',
      'phone': '+57 315 111 2233',
      'address': 'Avenida 68 #80-40',
      'isActive': true,
    },
  ];

  /// POST {baseUrl}/internal/user/login
  /// Body: { "data": { "emailOrDoc": "...", "password": "..." } }
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Obtener lista de eliminados y usuarios personalizados
    final deletedList = prefs.getStringList('user_deleted_documents_set') ?? [];
    final customUsersStr = prefs.getString('user_custom_users_list');
    List<dynamic> customUsersJson = [];
    if (customUsersStr != null && customUsersStr.isNotEmpty) {
      try {
        customUsersJson = jsonDecode(customUsersStr);
      } catch (_) {}
    }

    final String query = username.trim().toLowerCase();

    // Buscar si existe en customUsers o demoUsers
    Map<String, dynamic>? matchedUser;

    for (var u in customUsersJson) {
      if (u is Map) {
        final doc = (u['documentNumber'] ?? '').toString().trim().toLowerCase();
        final email = (u['email'] ?? '').toString().trim().toLowerCase();
        if ((doc.isNotEmpty && doc == query) || (email.isNotEmpty && email == query)) {
          matchedUser = Map<String, dynamic>.from(u);
          break;
        }
      }
    }

    if (matchedUser == null) {
      for (var u in _demoUsers) {
        final doc = (u['documentNumber'] ?? '').toString().trim().toLowerCase();
        final email = (u['email'] ?? '').toString().trim().toLowerCase();
        if ((doc.isNotEmpty && doc == query) || (email.isNotEmpty && email == query)) {
          matchedUser = Map<String, dynamic>.from(u);
          break;
        }
      }
    }

    // 2. Verificar estado de inactivación o eliminación
    if (matchedUser != null) {
      final docNum = (matchedUser['documentNumber'] ?? '').toString();
      final email = (matchedUser['email'] ?? '').toString();

      if (deletedList.contains(docNum) || (email.isNotEmpty && deletedList.contains(email))) {
        throw Exception('Llama al Contact Center, o acércate a una oficina. Usuario desactivado.');
      }

      final bool isActive = matchedUser['isActive'] ?? true;
      if (!isActive) {
        throw Exception('Llama al Contact Center, o acércate a una oficina. Usuario desactivado.');
      }
    } else {
      if (deletedList.contains(username.trim())) {
        throw Exception('Llama al Contact Center, o acércate a una oficina. Usuario desactivado.');
      }
    }

    // 3. Petición al Backend
    final uri = Uri.parse('$baseUrl/internal/user/login');
    final payload = {
      'data': {'emailOrDoc': username, 'password': password}
    };

    http.Response? resp;
    try {
      resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Si la red o backend no está disponible pero existe un usuario local activo
      if (matchedUser != null && (matchedUser['isActive'] ?? true)) {
        final userObj = {'data': matchedUser, 'token': 'demo_token'};
        await prefs.setString('auth_token', 'demo_token');
        await prefs.setString('auth_user', jsonEncode(userObj));
        return userObj;
      }
      throw Exception('Error de red o no se pudo conectar al servidor');
    }

    // ignore: avoid_print
    print('AuthService.login -> status: ${resp.statusCode}, body: ${resp.body}');

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      Map<String, dynamic> body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
      } catch (e) {
        throw Exception('Respuesta inválida del servidor (no JSON)');
      }

      dynamic userData;
      if (body['data'] is Map) {
        userData = body['data'];
      } else if (body['user'] is Map) {
        userData = body['user'];
      } else {
        userData = body;
      }

      if (userData is Map) {
        final docNum = (userData['documentNumber'] ?? '').toString();
        final email = (userData['email'] ?? '').toString();
        final bool isActive = userData['isActive'] ?? true;
        final String statusStr = (userData['status'] ?? '').toString().toUpperCase();

        if (!isActive ||
            statusStr == 'INACTIVE' ||
            statusStr == 'DISABLED' ||
            deletedList.contains(docNum) ||
            (email.isNotEmpty && deletedList.contains(email))) {
          throw Exception('Llama al Contact Center, o acércate a una oficina. Usuario desactivado.');
        }
      }

      dynamic token;
      if (body.containsKey('token')) token = body['token'];
      if (token == null && body.containsKey('access_token')) token = body['access_token'];
      if (token == null && body['data'] is Map && (body['data'] as Map).containsKey('token')) {
        token = (body['data'] as Map)['token'];
      }
      if (token == null && body['data'] is Map && (body['data'] as Map).containsKey('access_token')) {
        token = (body['data'] as Map)['access_token'];
      }

      if (token == null) token = 'demo_token';

      await prefs.setString('auth_token', token.toString());
      await prefs.setString('auth_user', jsonEncode(body));

      return body;
    } else {
      // Si backend responde 400/401/404 pero existe un usuario local activo
      if (matchedUser != null && (matchedUser['isActive'] ?? true)) {
        final userObj = {'data': matchedUser, 'token': 'demo_token'};
        await prefs.setString('auth_token', 'demo_token');
        await prefs.setString('auth_user', jsonEncode(userObj));
        return userObj;
      }

      String message = 'Credenciales inválidas o usuario no encontrado';
      try {
        final parsed = jsonDecode(resp.body);
        if (parsed is Map && (parsed['message'] != null || parsed['error'] != null)) {
          message = parsed['message'] ?? parsed['error'] ?? message;
        } else if (parsed is Map && parsed['data'] is Map && parsed['data']['message'] != null) {
          message = parsed['data']['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}