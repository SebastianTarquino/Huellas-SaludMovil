import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/api_config.dart';
import '../../services/announcement_services.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final Map<String, dynamic> announcement;

  const AnnouncementDetailScreen({Key? key, required this.announcement}) : super(key: key);

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _cellPhoneController;
  final AnnouncementService _announcementService = AnnouncementService();
  bool _isLoading = false;
  bool _canEdit = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.announcement["description"] ?? "",
    );
    _cellPhoneController = TextEditingController(
      text: widget.announcement["cellPhone"] ?? "",
    );
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('auth_user');

    bool allowed = false;
    if (userStr != null) {
      try {
        final parsed = jsonDecode(userStr);
        final userData = (parsed['data'] is Map) ? parsed['data'] : parsed;
        final role = (userData['role'] ?? 'CLIENTE').toString().toUpperCase();
        final userEmail = (userData['email'] ?? '').toString().trim().toLowerCase();
        final userName = (userData['name'] ?? '').toString().trim().toLowerCase();

        // ADMIN y VETERINARIO pueden editar cualquier anuncio
        if (role == 'ADMIN' || role == 'VETERINARIO') {
          allowed = true;
        } else if (role == 'CLIENTE') {
          // CLIENTE solo edita si fue creado por él
          final annEmail = (widget.announcement['emailUserCreated'] ?? '').toString().trim().toLowerCase();
          final annName = (widget.announcement['nameUserCreated'] ?? '').toString().trim().toLowerCase();

          if (userEmail.isNotEmpty && annEmail.isNotEmpty && userEmail == annEmail) {
            allowed = true;
          } else if (userName.isNotEmpty && annName.isNotEmpty && (annName.contains(userName) || userName.contains(annName))) {
            allowed = true;
          }
        }
      } catch (e) {
        print("Error al verificar permisos: $e");
      }
    }

    setState(() {
      _canEdit = allowed;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _cellPhoneController.dispose();
    super.dispose();
  }

  Future<void> _updateAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final id = widget.announcement["idAnnouncement"];
    final success = await _announcementService.updateAnnouncement(
      id: id.toString(),
      description: _descriptionController.text.trim(),
      cellPhone: _cellPhoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Anuncio actualizado con éxito!"),
            backgroundColor: Colors.purple,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al actualizar el anuncio"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _makeCall() async {
    final phone = _cellPhoneController.text.trim();
    if (phone.isNotEmpty) {
      final Uri url = Uri.parse('tel:$phone');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Llamando a $phone...")),
          );
        }
      }
    }
  }

  
  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Anuncio"),
        content: const Text("¿Estás seguro de que deseas eliminar este anuncio? Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              _deleteAnnouncement();
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAnnouncement() async {
    setState(() => _isLoading = true);
    final id = widget.announcement["idAnnouncement"];
    final success = await _announcementService.deleteAnnouncement(id.toString());
    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Anuncio eliminado exitosamente!"),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al eliminar el anuncio"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImage(String? announcementId) {
    if (announcementId == null || announcementId.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/img/images/placeholder.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: 240,
        ),
      );
    }

    final imageUrl =
        "${ApiConfig.internalBaseUrl}avatar-user/Announcement/$announcementId";

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 240,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/img/images/placeholder.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 240,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D1537);
    final fieldFillColor = isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF9F9F9);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Anuncios",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Large Product / Announcement Image
              _buildImage(widget.announcement["idAnnouncement"]),
              const SizedBox(height: 16),

              // Summary Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFE1BEE7),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, size: 18, color: Colors.purple),
                        const SizedBox(width: 6),
                        Text(
                          "Publicado por: ${widget.announcement["nameUserCreated"] ?? "Usuario"}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          _canEdit ? Icons.edit : Icons.lock_outline,
                          size: 16,
                          color: _canEdit ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _canEdit ? "Modo Edición Permitido" : "Modo Solo Lectura",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _canEdit ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Descripción
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Descripción",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Si es solo lectura, mostramos contenedor expandido con todo el texto completo
              if (!_canEdit)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: fieldFillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Text(
                    _descriptionController.text.isNotEmpty
                        ? _descriptionController.text
                        : "Sin descripción",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: textColor,
                    ),
                  ),
                )
              else
                TextFormField(
                  controller: _descriptionController,
                  maxLines: null, // Multilínea auto-expandible en modo edición
                  minLines: 3,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fieldFillColor,
                    suffixIcon: const Icon(Icons.edit, color: Colors.purple, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? "Requerido" : null,
                ),

              const SizedBox(height: 18),

              // Campo: Teléfono
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Teléfono",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              if (!_canEdit)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: fieldFillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Text(
                    _cellPhoneController.text.isNotEmpty
                        ? _cellPhoneController.text
                        : "No disponible",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                )
              else
                TextFormField(
                  controller: _cellPhoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fieldFillColor,
                    suffixIcon: const Icon(Icons.edit, color: Colors.purple, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? "Requerido" : null,
                ),

              const SizedBox(height: 32),

              // Botón Acción: Confirmar + Eliminar (si puede editar) o Contactar por Teléfono (si solo lectura)
              if (_canEdit)
                Column(
                  children: [
                    SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateAnnouncement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7E57C2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                "Confirmar",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 220,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _confirmDelete,
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text(
                          "Eliminar Anuncio",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: 240,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _makeCall,
                    icon: const Icon(Icons.phone, color: Colors.white),
                    label: const Text(
                      "Llamar al Anunciante",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
