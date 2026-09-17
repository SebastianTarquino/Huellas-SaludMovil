import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/users.dart';
import '../../services/users_services.dart';
import '../../widgets/userList.dart';
import '../../widgets/appbar.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final UserService _userService = UserService();
  final List<User> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isAuthorized = true;
  int _offset = 0;
  final int _limit = 20;

  // 🔍 Filtros y Búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRoleFilter = 'Todos';

  // Demo inicial de usuarios si el backend está vacío
  final List<User> _initialDemoUsers = [
    User(
      name: 'Armando',
      lastName: 'Puentes',
      role: 'ADMIN',
      documentNumber: '10987654321',
      email: 'armando@demo.com',
      phone: '+57 300 123 4567',
      address: 'Calle 100 #15-20',
      isActive: true,
    ),
    User(
      name: 'Valeria',
      lastName: 'Gómez',
      role: 'VETERINARIO',
      documentNumber: '10987654322',
      email: 'valeria@demo.com',
      phone: '+57 310 987 6543',
      address: 'Carrera 45 #30-10',
      isActive: true,
    ),
    User(
      name: 'Sebastian',
      lastName: 'Tarquino',
      role: 'CLIENTE',
      documentNumber: '10987654323',
      email: 'sebastian@demo.com',
      phone: '+57 320 456 7890',
      address: 'Transversal 14P #60-17',
      isActive: true,
    ),
    User(
      name: 'Clara',
      lastName: 'Heredia',
      role: 'CLIENTE',
      documentNumber: '10987654324',
      email: 'clara@demo.com',
      phone: '+57 315 111 2233',
      address: 'Avenida 68 #80-40',
      isActive: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkRoleAndLoad();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkRoleAndLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('auth_user');
      if (userStr != null) {
        final parsed = jsonDecode(userStr);
        final userData = (parsed['data'] is Map) ? parsed['data'] : parsed;
        final role = (userData['role'] ?? 'CLIENTE').toString().toUpperCase().trim();
        if (role == 'CLIENTE') {
          setState(() {
            _isAuthorized = false;
          });
          return;
        }
      }
    } catch (e) {
      print("Error al verificar rol en UserHomePage: $e");
    }
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final deletedDocs = await _userService.getDeletedDocuments();
      final fetchedUsers = await _userService.fetchUsers(
        limit: _limit,
        offset: _offset,
      );

      final prefs = await SharedPreferences.getInstance();
      final combinedList = <User>[];
      combinedList.addAll(fetchedUsers);

      for (var demoUser in _initialDemoUsers) {
        if (!deletedDocs.contains(demoUser.documentNumber)) {
          combinedList.add(demoUser);
        }
      }

      setState(() {
        final existingDocs = <String>{};
        final filteredList = <User>[];

        for (var u in combinedList) {
          if (!deletedDocs.contains(u.documentNumber) && !existingDocs.contains(u.documentNumber)) {
            existingDocs.add(u.documentNumber);

            // Cargar avatar guardado si está en SharedPreferences
            String? avatar = u.avatarBase64;
            final key = u.email != null && u.email!.isNotEmpty ? u.email : u.documentNumber;
            final savedAvatar = prefs.getString('user_profile_avatar_$key');
            if (savedAvatar != null && savedAvatar.isNotEmpty) {
              avatar = savedAvatar;
            }

            filteredList.add(u.copyWith(avatarBase64: avatar));
          }
        }

        _users.clear();
        _users.addAll(filteredList);
        _hasMore = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Filtrado dinámico por texto y rol
  List<User> get _filteredUsers {
    return _users.where((u) {
      // 1. Texto de búsqueda
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = u.name.toLowerCase().contains(q);
        final lastNameMatch = u.lastName.toLowerCase().contains(q);
        final docMatch = u.documentNumber.toLowerCase().contains(q);
        final emailMatch = (u.email ?? '').toLowerCase().contains(q);
        if (!nameMatch && !lastNameMatch && !docMatch && !emailMatch) {
          return false;
        }
      }

      // 2. Filtro de Rol
      if (_selectedRoleFilter != 'Todos') {
        if (u.role.toUpperCase().trim() != _selectedRoleFilter.toUpperCase().trim()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // ➕/✏️ Modal para Crear o Editar Usuario
  void _showUserModal({User? userToEdit}) {
    final isEditing = userToEdit != null;
    final nameController = TextEditingController(text: isEditing ? userToEdit.name : '');
    final lastNameController = TextEditingController(text: isEditing ? userToEdit.lastName : '');
    final emailController = TextEditingController(text: isEditing ? (userToEdit.email ?? '') : '');
    final docController = TextEditingController(text: isEditing ? userToEdit.documentNumber : '');
    final phoneController = TextEditingController(text: isEditing ? (userToEdit.phone ?? '') : '');
    final addressController = TextEditingController(text: isEditing ? (userToEdit.address ?? '') : '');
    final passwordController = TextEditingController();

    String selectedRole = isEditing ? userToEdit.role.toUpperCase().trim() : 'CLIENTE';
    if (!['ADMIN', 'VETERINARIO', 'CLIENTE'].contains(selectedRole)) {
      selectedRole = 'CLIENTE';
    }

    String? selectedBase64Image = isEditing ? userToEdit.avatarBase64 : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF1E1E2C) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickUserImage() async {
              try {
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 500,
                  maxHeight: 500,
                  imageQuality: 80,
                );
                if (picked != null) {
                  final bytes = await picked.readAsBytes();
                  setModalState(() {
                    selectedBase64Image = base64Encode(bytes);
                  });
                }
              } catch (e) {
                print("Error al seleccionar foto de usuario: $e");
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isEditing ? Icons.edit : Icons.person_add,
                              color: const Color(0xFF7E57C2),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEditing ? "Editar Usuario" : "Crear Nuevo Usuario",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Avatar Selector
                    Center(
                      child: GestureDetector(
                        onTap: pickUserImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: const Color(0xFF7E57C2).withOpacity(0.15),
                              backgroundImage: selectedBase64Image != null && selectedBase64Image!.isNotEmpty
                                  ? (selectedBase64Image!.startsWith('http')
                                      ? NetworkImage(selectedBase64Image!) as ImageProvider
                                      : MemoryImage(base64Decode(selectedBase64Image!)))
                                  : null,
                              child: selectedBase64Image == null || selectedBase64Image!.isEmpty
                                  ? const Icon(Icons.person, size: 40, color: Color(0xFF7E57C2))
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF7E57C2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nombres
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombres *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Apellidos
                    TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Apellidos *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Rol
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol de Usuario *',
                        prefixIcon: Icon(Icons.security),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ADMIN', child: Text('ADMINISTRADOR')),
                        DropdownMenuItem(value: 'VETERINARIO', child: Text('VETERINARIO')),
                        DropdownMenuItem(value: 'CLIENTE', child: Text('CLIENTE')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedRole = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Número de Documento
                    TextField(
                      controller: docController,
                      enabled: !isEditing,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número de Documento *',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Correo Electrónico
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Teléfono
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dirección
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (!isEditing) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña (por defecto 123456)',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7E57C2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: Text(
                          isEditing ? "Guardar Cambios" : "Crear Usuario",
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final lastName = lastNameController.text.trim();
                          final doc = docController.text.trim();
                          final email = emailController.text.trim();

                          if (name.isEmpty || lastName.isEmpty || doc.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Completa los campos obligatorios (*)"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          final updatedUser = User(
                            name: name,
                            lastName: lastName,
                            role: selectedRole,
                            documentNumber: doc,
                            email: email.isNotEmpty ? email : null,
                            phone: phoneController.text.trim(),
                            address: addressController.text.trim(),
                            avatarBase64: selectedBase64Image,
                            isActive: isEditing ? userToEdit.isActive : true,
                          );

                          // Guardar avatar localmente si se seleccionó foto
                          if (selectedBase64Image != null && selectedBase64Image!.isNotEmpty) {
                            final prefs = await SharedPreferences.getInstance();
                            final key = email.isNotEmpty ? email : doc;
                            await prefs.setString('user_profile_avatar_$key', selectedBase64Image!);
                          }

                          if (!isEditing) {
                            await _userService.registerUser(
                              name: name,
                              lastName: lastName,
                              email: email.isNotEmpty ? email : "$doc@huellas.com",
                              documentNumber: doc,
                              password: passwordController.text.trim().isNotEmpty
                                  ? passwordController.text.trim()
                                  : '123456',
                              phone: phoneController.text.trim(),
                              address: addressController.text.trim(),
                              role: selectedRole,
                              avatarBase64: selectedBase64Image,
                            );
                          }

                          setState(() {
                            final idx = _users.indexWhere((u) => u.documentNumber == doc);
                            if (idx >= 0) {
                              _users[idx] = updatedUser;
                            } else {
                              _users.insert(0, updatedUser);
                            }
                          });

                          await _userService.saveCustomUsers(_users);

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? "¡Usuario '$name $lastName' actualizado!"
                                    : "¡Usuario '$name $lastName' creado exitosamente!",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🚫 Toggle de Estado (Activar / Desactivar)
  void _toggleUserStatus(User user) async {
    final newStatus = !user.isActive;
    setState(() {
      final idx = _users.indexWhere((u) => u.documentNumber == user.documentNumber);
      if (idx >= 0) {
        _users[idx] = user.copyWith(isActive: newStatus);
      }
    });

    await _userService.saveCustomUsers(_users);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus
              ? "¡Usuario '${user.name} ${user.lastName}' activado!"
              : "Usuario '${user.name} ${user.lastName}' desactivado.",
        ),
        backgroundColor: newStatus ? Colors.green : Colors.orange,
      ),
    );
  }

  // 🗑️ Eliminar Usuario
  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text("Eliminar Usuario"),
          ],
        ),
        content: Text(
          "¿Estás seguro de que deseas eliminar a ${user.name} ${user.lastName}? Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(context);
              final userName = user.name;
              await _userService.deleteUser(user.documentNumber);
              setState(() {
                _users.removeWhere((u) => u.documentNumber == user.documentNumber);
              });
              await _userService.saveCustomUsers(_users);
              nav.pop();

              messenger.showSnackBar(
                SnackBar(
                  content: Text("Usuario '$userName' eliminado permanentemente."),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchBg = isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF3F4F6);
    final inputColor = isDark ? Colors.white : const Color(0xFF1F2937);

    if (!_isAuthorized) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Lista de Usuarios', showBackButton: true),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 60, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  "Acceso Restringido",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "La sección de Usuarios solo está disponible para usuarios con rol ADMINISTRADOR o VETERINARIO.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filteredList = _filteredUsers;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Lista de Usuarios', showBackButton: true),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7E57C2),
        onPressed: () => _showUserModal(userToEdit: null),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          "Crear Usuario",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 BARRA DE BÚSQUEDA
            Container(
              decoration: BoxDecoration(
                color: searchBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: inputColor, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Buscar usuario por nombre, doc o email...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // 🎛️ FILTROS POR ROL (Chips)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'ADMIN', 'VETERINARIO', 'CLIENTE'].map((roleOpt) {
                  final isSelected = _selectedRoleFilter == roleOpt;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(roleOpt),
                      selected: isSelected,
                      selectedColor: const Color(0xFF7E57C2),
                      backgroundColor: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF3F4F6),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedRoleFilter = roleOpt;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // 👥 LISTA DE USUARIOS
            Expanded(
              child: _users.isEmpty && _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: isDark ? Colors.grey[600] : Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No se encontraron usuarios",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Prueba ajustando la búsqueda o el filtro de rol",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : UserList(
                          users: filteredList,
                          onUserTap: (user) => _showUserModal(userToEdit: user),
                          onEditUser: (user) => _showUserModal(userToEdit: user),
                          onToggleStatus: (user) => _toggleUserStatus(user),
                          onDeleteUser: (user) => _deleteUser(user),
                          isLoading: _isLoading,
                          onLoadMore: _loadUsers,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
