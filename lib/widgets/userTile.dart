import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/users.dart';

class UserTile extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const UserTile({
    super.key,
    required this.user,
    required this.onTap,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Color del badge de Rol
    Color roleBgColor;
    Color roleTextColor = Colors.white;
    switch (user.role.toUpperCase().trim()) {
      case 'ADMIN':
        roleBgColor = const Color(0xFF7E57C2); // Púrpura
        break;
      case 'VETERINARIO':
        roleBgColor = const Color(0xFF00897B); // Verde Azulado
        break;
      default:
        roleBgColor = const Color(0xFF1E88E5); // Azul
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 📸 AVATAR / FOTO DEL USUARIO
              _buildUserAvatar(roleBgColor),
              const SizedBox(width: 14),

              // 👤 INFORMACIÓN DEL USUARIO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${user.name} ${user.lastName}".trim(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Fila de Badges: Rol + Estado
                    Row(
                      children: [
                        // Badge de Rol
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user.role,
                            style: TextStyle(
                              color: roleTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Badge de Estado (Activo / Inactivo)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: user.isActive
                                ? (isDark ? const Color(0xFF1B382B) : const Color(0xFFE8F5E9))
                                : (isDark ? const Color(0xFF3E1C1C) : const Color(0xFFFFEBEE)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user.isActive ? "Activo" : "Inactivo",
                            style: TextStyle(
                              color: user.isActive
                                  ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
                                  : (isDark ? const Color(0xFFE57373) : const Color(0xFFC62828)),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Documento / Email
                    Text(
                      user.email != null && user.email!.isNotEmpty
                          ? "${user.email} • Doc: ${user.documentNumber}"
                          : "Doc: ${user.documentNumber}",
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // ⚙️ MENÚ DE ACCIONES (Editar, Desactivar, Eliminar)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) {
                    onEdit!();
                  } else if (value == 'toggle' && onToggleStatus != null) {
                    onToggleStatus!();
                  } else if (value == 'delete' && onDelete != null) {
                    onDelete!();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: Color(0xFF7E57C2)),
                        SizedBox(width: 10),
                        Text("Editar Usuario"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          user.isActive ? Icons.block : Icons.check_circle_outline,
                          size: 18,
                          color: user.isActive ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 10),
                        Text(user.isActive ? "Desactivar Usuario" : "Activar Usuario"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 10),
                        Text("Eliminar Usuario", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(Color roleBgColor) {
    if (user.avatarBase64 != null && user.avatarBase64!.isNotEmpty) {
      final attach = user.avatarBase64!.trim();
      if (attach.startsWith('http://') || attach.startsWith('https://')) {
        return CircleAvatar(
          radius: 26,
          backgroundColor: roleBgColor.withOpacity(0.2),
          backgroundImage: NetworkImage(attach),
        );
      }
      try {
        final bytes = base64Decode(attach);
        return CircleAvatar(
          radius: 26,
          backgroundColor: roleBgColor.withOpacity(0.2),
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        // Fallback a iniciales
      }
    }

    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';
    return CircleAvatar(
      radius: 26,
      backgroundColor: roleBgColor.withOpacity(0.15),
      child: Text(
        initial,
        style: TextStyle(
          color: roleBgColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
