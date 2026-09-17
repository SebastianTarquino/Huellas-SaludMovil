class User {
  final String name;
  final String lastName;
  final String role;
  final String documentNumber;
  final String? email;
  final String? phone;
  final String? address;
  final String? avatarBase64;
  final bool isActive;

  User({
    required this.name,
    required this.lastName,
    required this.role,
    required this.documentNumber,
    this.email,
    this.phone,
    this.address,
    this.avatarBase64,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    return User(
      name: data['name'] ?? '',
      lastName: data['lastName'] ?? '',
      role: (data['role'] ?? 'CLIENTE').toString().toUpperCase().trim(),
      documentNumber: (data['documentNumber'] ?? '').toString(),
      email: data['email'],
      phone: data['phone'],
      address: data['address'],
      avatarBase64: data['avatarBase64'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastName': lastName,
      'role': role,
      'documentNumber': documentNumber,
      'email': email,
      'phone': phone,
      'address': address,
      'avatarBase64': avatarBase64,
      'isActive': isActive,
    };
  }

  User copyWith({
    String? name,
    String? lastName,
    String? role,
    String? documentNumber,
    String? email,
    String? phone,
    String? address,
    String? avatarBase64,
    bool? isActive,
  }) {
    return User(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      documentNumber: documentNumber ?? this.documentNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarBase64: avatarBase64 ?? this.avatarBase64,
      isActive: isActive ?? this.isActive,
    );
  }
}