import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.announcement["description"] ?? "",
    );
    _cellPhoneController = TextEditingController(
      text: widget.announcement["cellPhone"] ?? "",
    );
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
          "ANUNCIOS",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Title: SE BUSCA / ANUNCIO
              Text(
                "SE BUSCA",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.black,
                  letterSpacing: 2.0,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),

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
                    Text(
                      "Publicado por: ${widget.announcement["nameUserCreated"] ?? "Usuario"}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Contacto actual: ${widget.announcement["cellPhone"] ?? "No disponible"}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Input 1: Descripción
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
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
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

              // Input 2: Teléfono
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

              // Purple Button: Confirmar
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
