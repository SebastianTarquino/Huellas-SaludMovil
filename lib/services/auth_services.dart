// ...existing code...
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// ...existing code...

class AuthService {
  final String baseUrl;
  AuthService({required this.baseUrl});

  /// POST {baseUrl}/internal/user/login
  /// Body: { "data": { "emailOrDoc": "...", "password": "..." } }
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/internal/user/login');
    final payload = {
      'data': {'emailOrDoc': username, 'password': password}
    };

    http.Response resp;
    try {
      resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));
    } on SocketException {
      throw Exception('Error de red: no se puede conectar al servidor');
    } on HandshakeException {
      throw Exception('Error SSL/Handshake con el servidor');
    } on HttpException {
      throw Exception('Error HTTP al conectar con el servidor');
    } on FormatException {
      throw Exception('Error de formato en la petición');
    } on TimeoutException {
      throw Exception('Timeout: el servidor no respondió a tiempo');
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

      dynamic token;
      if (body.containsKey('token')) token = body['token'];
      if (token == null && body.containsKey('access_token')) token = body['access_token'];
      if (token == null && body['data'] is Map && (body['data'] as Map).containsKey('token')) {
        token = (body['data'] as Map)['token'];
      }
      if (token == null && body['data'] is Map && (body['data'] as Map).containsKey('access_token')) {
        token = (body['data'] as Map)['access_token'];
      }

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token.toString());
        await prefs.setString('auth_user', jsonEncode(body));
      }

      return body;
    } else {
      String message = 'Error ${resp.statusCode}';
      try {
        final parsed = jsonDecode(resp.body);
        if (parsed is Map && (parsed['message'] != null || parsed['error'] != null)) {
          message = parsed['message'] ?? parsed['error'] ?? message;
        } else if (parsed is Map && parsed['data'] is Map && parsed['data']['message'] != null) {
          message = parsed['data']['message'];
        } else {
          message = resp.body.toString();
        }
      } catch (_) {
        message = resp.body.isNotEmpty ? resp.body : message;
      }
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