import 'package:flutter/material.dart';
import '../../widgets/appbar.dart';
import '../../widgets/notificationsList.dart';
import '../../theme/theme_app.dart';

/// Pantalla principal que muestra la lista de notificaciones
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // ✅ del tema
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Hoy',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineLarge!.color, // ✅ del tema
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (_, i) =>
                    NotificacionCard(notificacion: notificaciones[i]),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: notificaciones.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta individual para cada notificación
class NotificacionCard extends StatelessWidget {
  final Notificacion notificacion;
  const NotificacionCard({super.key, required this.notificacion});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.8), // ✅ color del tema
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono o emoji a la izquierda
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: notificacion.emoji != null
                ? Text(
                    notificacion.emoji!,
                    style: const TextStyle(fontSize: 24),
                  )
                : Icon(notificacion.icon, color: Colors.white, size: 24),
          ),
          // Mensaje y hora
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notificacion.mensaje,
                  style: TextStyle(
                    color: Colors.white, // ✅ color del tema
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    notificacion.hora,
                    style: TextStyle(
                      color: Colors.white, // ✅ color del tema
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}