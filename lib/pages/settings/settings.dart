import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_state.dart';
import '../../services/users_services.dart';

class SettingsScreen extends StatefulWidget {
  final String username;
  final String password;

  const SettingsScreen({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();

  String _email = "";
  String _documentNumber = "";
  String _displayName = "";
  String _userKey = "";

  // ⚙️ Preferencias Guardadas
  String _selectedTheme = "Oscuro"; // 'Claro', 'Oscuro', 'Sistema'
  String _selectedLanguage = "Español"; // 'Español', 'English'
  bool _pushNotifications = true;
  bool _soundAlerts = true;
  bool _biometricSecurity = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('auth_user');

      if (userStr != null) {
        final parsed = jsonDecode(userStr);
        final userData = (parsed['data'] is Map) ? parsed['data'] : parsed;
        final name = (userData['name'] ?? '').toString().trim();
        final lastName = (userData['lastName'] ?? '').toString().trim();
        final email = (userData['email'] ?? '').toString().trim();
        final doc = (userData['documentNumber'] ?? '').toString().trim();

        setState(() {
          _displayName = "$name $lastName".trim();
          _email = email.isNotEmpty ? email : "${widget.username}@huellassalud.com";
          _documentNumber = doc;
          _userKey = doc.isNotEmpty ? doc : email;
        });
      } else {
        setState(() {
          _displayName = widget.username;
          _email = "${widget.username}@huellassalud.com";
          _userKey = widget.username;
        });
      }

      // Cargar preferencias guardadas
      setState(() {
        _selectedTheme = prefs.getString('pref_theme_mode') ?? 'Oscuro';
        _selectedLanguage = prefs.getString('pref_language') ?? 'Español';
        _pushNotifications = prefs.getBool('pref_push_notifications') ?? true;
        _soundAlerts = prefs.getBool('pref_sound_alerts') ?? true;
        _biometricSecurity = prefs.getBool('pref_biometrics') ?? false;
      });
    } catch (e) {
      print("Error al cargar configuración: $e");
    }
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }

  // ✉️ MODAL: Cambiar Email
  void _showChangeEmailModal() {
    final emailController = TextEditingController(text: _email);
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, -5))
                ],
              ),
              child: Form(
                key: formKey,
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7E57C2).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.email, color: Color(0xFF7E57C2), size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cambiar Correo",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Ingresa tu nueva dirección de correo",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Correo Electrónico",
                        prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF7E57C2)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFF5F3F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "El correo es obligatorio";
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                          return "Ingresa un correo electrónico válido";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7E57C2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => isSubmitting = true);

                                final newEmail = emailController.text.trim();
                                final success = await _userService.updateUserData(_userKey, {'email': newEmail});

                                if (success) {
                                  // Actualizar en SharedPreferences
                                  final prefs = await SharedPreferences.getInstance();
                                  final userStr = prefs.getString('auth_user');
                                  if (userStr != null) {
                                    try {
                                      final parsed = jsonDecode(userStr);
                                      if (parsed is Map) {
                                        if (parsed['data'] is Map) {
                                          parsed['data']['email'] = newEmail;
                                        } else {
                                          parsed['email'] = newEmail;
                                        }
                                        await prefs.setString('auth_user', jsonEncode(parsed));
                                      }
                                    } catch (_) {}
                                  }

                                  setState(() => _email = newEmail);
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("¡Correo actualizado con éxito en PostgreSQL!"),
                                      backgroundColor: Color(0xFF7E57C2),
                                    ),
                                  );
                                } else {
                                  setModalState(() => isSubmitting = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Error al actualizar correo en el servidor"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text("Guardar Cambios", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  // 🔑 MODAL: Cambiar Contraseña
  void _showChangePasswordModal() {
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, -5))
                ],
              ),
              child: Form(
                key: formKey,
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock, color: Colors.blue, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cambiar Contraseña",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Crea una clave nueva para proteger tu cuenta",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: newPassController,
                      obscureText: obscureNew,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Nueva Contraseña",
                        prefixIcon: const Icon(Icons.key, color: Colors.blue),
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setModalState(() => obscureNew = !obscureNew),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFF5F3F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "Ingresa la nueva contraseña";
                        if (val.trim().length < 6) return "La contraseña debe tener mínimo 6 caracteres";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: confirmPassController,
                      obscureText: obscureConfirm,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Confirmar Nueva Contraseña",
                        prefixIcon: const Icon(Icons.check_circle_outline, color: Colors.blue),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setModalState(() => obscureConfirm = !obscureConfirm),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFF5F3F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      validator: (val) {
                        if (val != newPassController.text) return "Las contraseñas no coinciden";
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => isSubmitting = true);

                                final newPass = newPassController.text.trim();
                                final success = await _userService.updateUserData(_userKey, {'password': newPass});

                                if (success) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("¡Contraseña actualizada con éxito en PostgreSQL!"),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );
                                } else {
                                  setModalState(() => isSubmitting = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Error al actualizar contraseña"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text("Actualizar Contraseña", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  // 🎨 MODAL: Tema de la App
  void _showThemeSelectorModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Seleccionar Tema", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildRadioOption("Claro", Icons.wb_sunny_outlined, Colors.orange),
              _buildRadioOption("Oscuro", Icons.nightlight_round, Colors.purple),
              _buildRadioOption("Sistema", Icons.settings_suggest, Colors.grey),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRadioOption(String themeName, IconData icon, Color color) {
    final isSelected = _selectedTheme == themeName;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(themeName, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF7E57C2)) : null,
      onTap: () async {
        setState(() => _selectedTheme = themeName);
        await AppStateNotifier.updateTheme(themeName);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tema cambiado a: $themeName"),
            backgroundColor: const Color(0xFF7E57C2),
          ),
        );
      },
    );
  }

  // 🌐 MODAL: Idioma
  void _showLanguageSelectorModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Idioma de la Aplicación", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Text("🇪🇸", style: TextStyle(fontSize: 24)),
                title: const Text("Español (América Latina)", style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: _selectedLanguage == "Español" ? const Icon(Icons.check_circle, color: Color(0xFF7E57C2)) : null,
                onTap: () async {
                  setState(() => _selectedLanguage = "Español");
                  await AppStateNotifier.updateLanguage("Español");
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Idioma configurado en Español 🇪🇸")),
                  );
                },
              ),
              ListTile(
                leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
                title: const Text("English (United States)", style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: _selectedLanguage == "English" ? const Icon(Icons.check_circle, color: Color(0xFF7E57C2)) : null,
                onTap: () async {
                  setState(() => _selectedLanguage = "English");
                  await AppStateNotifier.updateLanguage("English");
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Language set to English 🇺🇸")),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ℹ️ MODAL: Términos y Privacidad
  void _showTermsModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.shield, color: Color(0xFF7E57C2)),
            SizedBox(width: 10),
            Text("Políticas & Privacidad"),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            "Huellas y Salud se compromete a proteger la privacidad de sus usuarios y las historias clínicas de sus mascotas.\n\n"
            "• Todos los datos recopilados (consultas, vacunaciones, anuncios) se almacenan de forma segura mediante encriptación SSL y bases de datos PostgreSQL.\n"
            "• No compartimos información personal con terceros sin autorización previa.\n"
            "• Puedes solicitar la eliminación completa de tus registros en cualquier momento.\n\n"
            "Versión oficial v1.2.0 - © 2026 Huellas y Salud Mobile.",
            style: TextStyle(height: 1.4, fontSize: 13),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7E57C2), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Entendido"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D1537);
    final subtitleColor = isDark ? const Color(0xFFB0BEC5) : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF5F3F9),
      appBar: AppBar(
        title: const Text("Configuración", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7E57C2), Color(0xFF512DA8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.settings_suggest, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ajustes & Seguridad",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _displayName.isNotEmpty ? "Usuario: $_displayName" : "Gestiona tu cuenta y preferencias",
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔐 SECCIÓN: CUENTA Y SEGURIDAD
            _buildSectionHeader("Cuenta & Seguridad", Icons.security, isDark),
            const SizedBox(height: 12),

            _buildSettingCard(
              context: context,
              icon: Icons.email_outlined,
              iconBgColor: Colors.blue,
              title: "Cambiar Email",
              description: "Correo: $_email",
              trailingBadge: _email.isNotEmpty ? "Actual" : null,
              onTap: _showChangeEmailModal,
              isDark: isDark,
              cardBgColor: cardBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
            const SizedBox(height: 12),

            _buildSettingCard(
              context: context,
              icon: Icons.lock_outline,
              iconBgColor: Colors.indigo,
              title: "Cambiar Contraseña",
              description: "Establece una nueva contraseña segura",
              onTap: _showChangePasswordModal,
              isDark: isDark,
              cardBgColor: cardBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
            const SizedBox(height: 12),

            _buildSwitchCard(
              icon: Icons.fingerprint,
              iconBgColor: Colors.teal,
              title: "Seguridad Biométrica / PIN",
              description: "Requerir huella o clave al abrir la app",
              value: _biometricSecurity,
              onChanged: (val) async {
                setState(() => _biometricSecurity = val);
                await _savePreference('pref_biometrics', val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(val ? "Seguridad biométrica activada 🔒" : "Seguridad biométrica desactivada"),
                  ),
                );
              },
              isDark: isDark,
              cardBgColor: cardBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),

            const SizedBox(height: 28),

            // 🎨 SECCIÓN: PERSONALIZACIÓN
            _buildSectionHeader("Personalización & Aspecto", Icons.palette_outlined, isDark),
            const SizedBox(height: 12),

            _buildSettingCard(
              context: context,
              icon: Icons.brightness_6_outlined,
              iconBgColor: Colors.purple,
              title: "Tema de la App",
              description: "Personaliza colores y modo oscuro",
              trailingBadge: _selectedTheme,
              onTap: _showThemeSelectorModal,
              isDark: isDark,
              cardBgColor: cardBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
            const SizedBox(height: 12),

            _buildSettingCard(
              context: context,
              icon: Icons.language,
              iconBgColor: Colors.deepOrange,
              title: "Idioma",
              description: "Idioma principal de la plataforma",
              trailingBadge: _selectedLanguage == "Español" ? "🇪🇸 Español" : "🇺🇸 English",
              onTap: _showLanguageSelectorModal,
              isDark: isDark,
              cardBgColor: cardBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),

            const SizedBox(height: 28),

            // 🔔 SECCIÓN: NOTIFICACIONES
            _buildSectionHeader("Notificaciones & Alertas", Icons.notifications_none, isDark),
            const SizedBox(height: 12),

            _buildSwitchCard(
              icon: Icons.notifications_active_outlined,
              iconBgColor: Colors.amber[800]!,
              title: "Notificaciones Push",
              description: "Recordatorios de citas e historias clínicas",
              value: _pushNotifications,
              onChanged: (val) async {
                setState(() => _pushNotifications = val);
                await _savePreference('pref_push_notifications', val);
              },
              isDark: isDark,
              cardBgColor: cardBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
            const SizedBox(height: 12),

            _buildSwitchCard(
              icon: Icons.volume_up_outlined,
              iconBgColor: Colors.pink,
              title: "Sonido de Alertas",
              description: "Reproducir sonido al recibir avisos",
              value: _soundAlerts,
              onChanged: (val) async {
                setState(() => _soundAlerts = val);
                await _savePreference('pref_sound_alerts', val);
              },
              isDark: isDark,
              cardBgColor: cardBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),

            const SizedBox(height: 28),

            // ℹ️ SECCIÓN: ACERCA DE
            _buildSectionHeader("Información & Legal", Icons.info_outline, isDark),
            const SizedBox(height: 12),

            _buildSettingCard(
              context: context,
              icon: Icons.verified_user_outlined,
              iconBgColor: Colors.green,
              title: "Términos & Políticas de Privacidad",
              description: "Protección de datos e información técnica",
              onTap: _showTermsModal,
              isDark: isDark,
              cardBgColor: cardBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                "Huellas y Salud Mobile v1.2.0 • Build 2026",
                style: TextStyle(fontSize: 12, color: subtitleColor, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF7E57C2)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFD1C4E9) : const Color(0xFF4A148C),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String description,
    required VoidCallback onTap,
    String? trailingBadge,
    required bool isDark,
    required Color cardBgColor,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.purple.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFEDE7F6),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconBgColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: TextStyle(fontSize: 12, color: subtitleColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (trailingBadge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7E57C2).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      trailingBadge,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7E57C2)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
    required Color cardBgColor,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.purple.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFEDE7F6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconBgColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: const Color(0xFF7E57C2),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
