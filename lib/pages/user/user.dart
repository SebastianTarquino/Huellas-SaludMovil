import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login.dart';
import '../invoices/history_invoice.dart';
import '../pets/pets.dart';
import '../settings/settings.dart';
import './users.dart';

class UserScreen extends StatefulWidget {
  final String username;
  final String password;
  final VoidCallback? onGoToHome;

  const UserScreen({
    super.key,
    required this.username,
    required this.password,
    this.onGoToHome,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _displayName = "Jaime Londoño";
  String _email = "";
  String _role = "CLIENTE";
  String _documentNumber = "";
  String _searchQuery = "";

  Uint8List? _webAvatarBytes;
  io.File? _selectedAvatarFile;
  String? _savedAvatarBase64;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getUserStorageKey() {
    if (_email.trim().isNotEmpty) {
      return _email.trim().toLowerCase();
    }
    if (_documentNumber.trim().isNotEmpty) {
      return _documentNumber.trim().toLowerCase();
    }
    if (widget.username.trim().isNotEmpty) {
      return widget.username.trim().toLowerCase();
    }
    return "default_user";
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cargar datos de usuario
      final userStr = prefs.getString('auth_user');
      if (userStr != null) {
        final parsed = jsonDecode(userStr);
        final userData = (parsed['data'] is Map) ? parsed['data'] : parsed;
        final name = (userData['name'] ?? '').toString().trim();
        final lastName = (userData['lastName'] ?? '').toString().trim();
        final email = (userData['email'] ?? '').toString().trim();
        final role = (userData['role'] ?? 'CLIENTE').toString().trim();
        final doc = (userData['documentNumber'] ?? '').toString().trim();

        setState(() {
          if (name.isNotEmpty || lastName.isNotEmpty) {
            _displayName = "$name $lastName".trim();
          } else if (widget.username.isNotEmpty) {
            _displayName = widget.username;
          }
          _email = email.isNotEmpty ? email : "${widget.username}@demo.com";
          _role = role;
          _documentNumber = doc;
        });
      } else if (widget.username.isNotEmpty) {
        setState(() {
          _displayName = widget.username;
          _email = "${widget.username}@demo.com";
        });
      }

      // Cargar foto de perfil guardada única para este usuario
      final userKey = _getUserStorageKey();
      final savedAvatar = prefs.getString('user_profile_avatar_$userKey');
      if (savedAvatar != null && savedAvatar.isNotEmpty) {
        setState(() {
          _savedAvatarBase64 = savedAvatar;
        });
      } else {
        setState(() {
          _savedAvatarBase64 = null;
          _webAvatarBytes = null;
          _selectedAvatarFile = null;
        });
      }
    } catch (e) {
      print("Error al cargar datos del usuario: $e");
    }
  }

  // 📸 Cambiar / Actualizar foto de perfil
  Future<void> _pickProfileImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF7E57C2)),
                title: const Text('Seleccionar de la Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF7E57C2)),
                title: const Text('Tomar Foto con Cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 75,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64Str = "data:image/jpeg;base64,${base64Encode(bytes)}";

        final userKey = _getUserStorageKey();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_profile_avatar_$userKey', base64Str);

        if (kIsWeb) {
          setState(() {
            _webAvatarBytes = bytes;
            _savedAvatarBase64 = base64Str;
          });
        } else {
          setState(() {
            _selectedAvatarFile = io.File(picked.path);
            _savedAvatarBase64 = base64Str;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Foto de perfil actualizada con éxito!"),
              backgroundColor: Color(0xFF7E57C2),
            ),
          );
        }
      }
    } catch (e) {
      print("Error al seleccionar foto de perfil: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al cargar la foto de perfil"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión cerrada exitosamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showUpdateProfileModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Perfil del Usuario",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildProfileInfoRow(Icons.person, "Nombre", _displayName),
            const SizedBox(height: 12),
            _buildProfileInfoRow(Icons.email, "Email", _email.isNotEmpty ? _email : "No registrado"),
            const SizedBox(height: 12),
            _buildProfileInfoRow(Icons.badge, "Rol", _role),
            if (_documentNumber.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildProfileInfoRow(Icons.credit_card, "Documento", _documentNumber),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF7E57C2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _pickProfileImage();
                    },
                    icon: const Icon(Icons.camera_alt, color: Color(0xFF7E57C2)),
                    label: const Text("Cambiar Foto", style: TextStyle(color: Color(0xFF7E57C2), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF7E57C2)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  void _showComingSoon(String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Módulo '$moduleName' próximamente disponible"),
        backgroundColor: const Color(0xFF7E57C2),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildAvatarWidget() {
    Widget avatarChild;

    if (kIsWeb && _webAvatarBytes != null) {
      avatarChild = Image.memory(_webAvatarBytes!, fit: BoxFit.cover, width: 96, height: 96);
    } else if (!kIsWeb && _selectedAvatarFile != null) {
      avatarChild = Image.file(_selectedAvatarFile!, fit: BoxFit.cover, width: 96, height: 96);
    } else if (_savedAvatarBase64 != null && _savedAvatarBase64!.isNotEmpty) {
      try {
        String clean = _savedAvatarBase64!;
        if (clean.contains(',')) clean = clean.split(',').last;
        final bytes = base64Decode(clean.trim());
        avatarChild = Image.memory(bytes, fit: BoxFit.cover, width: 96, height: 96);
      } catch (e) {
        avatarChild = Image.asset('assets/img/images/placeholder.png', fit: BoxFit.cover, width: 96, height: 96);
      }
    } else {
      avatarChild = Image.asset('assets/img/images/placeholder.png', fit: BoxFit.cover, width: 96, height: 96);
    }

    return GestureDetector(
      onTap: _pickProfileImage,
      child: Stack(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(child: avatarChild),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF7E57C2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF12121A) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final searchBgColor = isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF3F4F6);
    final dividerColor = isDark ? const Color(0xFF2C2C3E) : const Color(0xFFE5E7EB);

    final bool canViewUsers =
        _role.toUpperCase().trim() == 'ADMIN' || _role.toUpperCase().trim() == 'VETERINARIO';

    final section1Items = [
      _MenuItemData(
        title: "Inicio",
        emoji: "🏠",
        onTap: () {
          if (widget.onGoToHome != null) {
            widget.onGoToHome!();
          } else {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
      ),
      if (canViewUsers)
        _MenuItemData(
          title: "Usuarios",
          emoji: "👥",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserHomePage()),
            );
          },
        ),
      _MenuItemData(
        title: "Mascotas",
        emoji: "🐾",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PetHomePage()),
          );
        },
      ),
      _MenuItemData(
        title: "Facturas",
        emoji: "📑",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistorialFacturasScreen()),
          );
        },
      ),
      _MenuItemData(
        title: "Consultas / Citas",
        emoji: "🩺",
        onTap: () => _showComingSoon("Consultas / Citas"),
      ),
      _MenuItemData(
        title: "Calendario (Agenda)",
        emoji: "📅",
        onTap: () => _showComingSoon("Calendario (Agenda)"),
      ),
    ];

    final section2Items = [
      _MenuItemData(
        title: "Actualizar Perfil",
        emoji: "✏️",
        onTap: () => _showUpdateProfileModal(context),
      ),
      _MenuItemData(
        title: "Configuración / Seguridad",
        emoji: "⚙️",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsScreen(
                username: widget.username,
                password: widget.password,
              ),
            ),
          );
        },
      ),
      _MenuItemData(
        title: "Cerrar sesión",
        emoji: "🚪",
        onTap: () => _showLogoutConfirmation(context),
      ),
    ];

    final filteredSection1 = section1Items.where((item) {
      return item.title.toLowerCase().contains(_searchQuery);
    }).toList();

    final filteredSection2 = section2Items.where((item) {
      return item.title.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔍 Barra de búsqueda Centrada estilo Maquetado
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: searchBgColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: titleColor, fontSize: 14),
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 14),
                      child: Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 36),
                    hintText: "Buscar",
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 👤 Avatar con botón de cámara e información del usuario
              Center(child: _buildAvatarWidget()),

              const SizedBox(height: 12),

              Text(
                _displayName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),

              const SizedBox(height: 20),

              Divider(height: 1, thickness: 1, color: dividerColor),

              const SizedBox(height: 8),

              // 📋 Lista Principal de Opciones con Emojis
              ...filteredSection1.map((item) => _buildMenuItem(item, titleColor)),

              if (filteredSection1.isNotEmpty && filteredSection2.isNotEmpty) ...[
                const SizedBox(height: 8),
                Divider(height: 1, thickness: 1, color: dividerColor),
                const SizedBox(height: 8),
              ],

              // ⚙️ Lista Secundaria de Opciones con Emojis
              ...filteredSection2.map((item) => _buildMenuItem(item, titleColor)),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItemData item, Color titleColor) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 8.0),
        child: Row(
          children: [
            Text(
              item.emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemData {
  final String title;
  final String emoji;
  final VoidCallback onTap;

  _MenuItemData({
    required this.title,
    required this.emoji,
    required this.onTap,
  });
}
