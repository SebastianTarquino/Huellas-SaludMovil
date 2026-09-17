import 'package:flutter/material.dart';
import '../models/users.dart';
import './userTile.dart';

class UserList extends StatelessWidget {
  final List<User> users;
  final Function(User) onUserTap;
  final Function(User)? onEditUser;
  final Function(User)? onToggleStatus;
  final Function(User)? onDeleteUser;
  final bool isLoading;
  final VoidCallback onLoadMore;

  const UserList({
    super.key,
    required this.users,
    required this.onUserTap,
    this.onEditUser,
    this.onToggleStatus,
    this.onDeleteUser,
    required this.isLoading,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < users.length) {
          final user = users[index];
          return UserTile(
            user: user,
            onTap: () => onUserTap(user),
            onEdit: onEditUser != null ? () => onEditUser!(user) : null,
            onToggleStatus: onToggleStatus != null ? () => onToggleStatus!(user) : null,
            onDelete: onDeleteUser != null ? () => onDeleteUser!(user) : null,
          );
        } else {
          onLoadMore();
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
