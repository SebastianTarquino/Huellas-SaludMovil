import 'package:flutter/services.dart';

class User {
  final String name;
  final String lastName;
  final String role;
  final String documentNumber;

  User({
    required this.name,
    required this.lastName,
    required this.role,
    required this.documentNumber
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return User(
      name: data['name'],
      lastName: data['lastName'],
      role: data['role'],
      documentNumber: data['documentNumber']
    );
  }
}