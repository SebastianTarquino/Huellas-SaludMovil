import 'package:flutter/material.dart';
import '../pages/notifications/notifications.dart';
/// Modelo de datos de una notificación
class Notificacion {
  final IconData icon;
  final String mensaje;
  final String hora;
  final String? emoji;

  const Notificacion({
    required this.icon,
    required this.mensaje,
    required this.hora,
    this.emoji,
  });
}

/// Lista de notificaciones de ejemplo
const List<Notificacion> notificaciones = [
  Notificacion(
    icon: Icons.person,
    mensaje:
        'El paquete está en camino.\nConsulta el estado con el código: #ABC123.',
    hora: '08:40 AM',
    emoji: '📦',
  ),
  Notificacion(
    icon: Icons.pets,
    mensaje:
        'La vacuna contra la rabia de tu mascota está próxima a vencer. Agenda su renovación.',
    hora: '10:59 AM',
    emoji: '🐱',
  ),
  Notificacion(
    icon: Icons.pets,
    mensaje:
        'Por compras mayores a \$100.000, el envío es totalmente gratis.',
    hora: '02:05 PM',
    emoji: '🚙',
  ),
  Notificacion(
    icon: Icons.person,
    mensaje:
        'Tu servicio ha sido agendado para el 12/08/2025 a las 02:00 PM.',
    hora: '08:10 PM',
    emoji: '🩺',
  ),
];