import 'package:flutter/material.dart';
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
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newUsers = await _userService.fetchUsers(
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        if (newUsers.isEmpty) {
          _hasMore = false;
        } else {
          final existingIds = _users.map((u) => u.documentNumber).toSet();
          final filtered =
              newUsers.where((u) => !existingIds.contains(u.documentNumber)).toList();
          _users.addAll(filtered);
          _offset += _limit;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar(e.toString());
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onUserTap(User user) {
    // Aquí navegas o muestras detalles
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${user.name} ${user.lastName}"),
        content: Text("Rol: ${user.role}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          const CustomAppBar(title: 'Lista de Usuarios', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _users.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: UserList(
                      users: _users,
                      onUserTap: _onUserTap,
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
