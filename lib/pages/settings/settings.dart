import 'package:huellas_salud_movil/widgets/appbar.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final String username;
  final String password;

  const SettingsScreen({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Configuración'),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Cuenta',
              textAlign: TextAlign.left),
            const SizedBox(height: 20),
            ListView(
              shrinkWrap: true,         // para que no tome todo el espacio verticala que no haga scroll si está dentro de otro scrollable
              children: [
                _buildFeatureCard(context, Icons.email, 'Cambiar Email', 'Actualiza tu dirección de correo electrónico', Colors.blue),
                const SizedBox(height: 10),
                _buildFeatureCard(context, Icons.lock, 'Cambiar contraseña', 'Establece una nueva contraseña segura', Colors.blue),
                const SizedBox(height: 10),
                _buildFeatureCard(context, Icons.palette, 'Tema de la App', 'Personaliza colores y aspecto', Colors.blue),
                const SizedBox(height: 10),
                _buildFeatureCard(context, Icons.language, 'Idioma', 'Seleccione el idioma de la aplicación', Colors.blue),
              ],
            )
          ],
        ),
      )
    );
  }


 Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String description, Color color) {
  return InkWell(
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Has pulsado "$title"')),
      );
    },
    child: Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(description),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
          ],
        ),
      ),
    ),
  );
}

}
