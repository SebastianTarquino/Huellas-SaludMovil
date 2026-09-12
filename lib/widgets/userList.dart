import 'package:flutter/material.dart';
import '../models/users.dart';
import './userTile.dart';

class UserList extends StatelessWidget {
  final List<User> users;
  final Function(User) onUserTap;
  final bool isLoading;
  final VoidCallback onLoadMore;

  const UserList({
    super.key,
    required this.users,
    required this.onUserTap,
    required this.isLoading,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < users.length) {
          return UserTile(
            user: users[index],
            onTap: () => onUserTap(users[index]),
          );
        } else {
          onLoadMore();
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
