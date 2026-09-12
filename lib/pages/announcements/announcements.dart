import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '../../services/announcement_services.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({Key? key}) : super(key: key);

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _cellPhoneController = TextEditingController();
  final AnnouncementService _announcementService = AnnouncementService();

  Uint8List? _webImageBytes;
  io.File? _selectedImage;  
  bool _isLoading = false;

  // 📸 Seleccionar imagen
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => _webImageBytes = bytes);
      } else {
        setState(() => _selectedImage = io.File(picked.path));
      }
    }
  }

  // 🖼️ Mostrar imagen seleccionada o placeholder
  Widget _buildPreviewImage() {
    if (kIsWeb && _webImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          _webImageBytes!,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (!kIsWeb && _selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImage!,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/img/images/placeholder.png',
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  // 🟣 Crear anuncio y subir imagen
  Future<void> _createAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final id = await _announcementService.createAnnouncement(
  description: _descriptionController.text.trim(),
  cellPhone: _cellPhoneController.text.trim(),
  
      );

      if (id != null) {
        if (!kIsWeb && _selectedImage != null) {
          await _announcementService.uploadAnnouncementImage(
            announcementId: id,
            imageFile: _selectedImage!,
          );
        } else if (kIsWeb && _webImageBytes != null) {
          // 🟣 Subida para web
          await _announcementService.uploadAnnouncementImageWeb(
            announcementId: id,
            bytes: _webImageBytes!,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Anuncio creado exitosamente")),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("❌ Error al crear anuncio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al crear el anuncio")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("Crear anuncio"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _buildPreviewImage(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cellPhoneController,
                decoration: const InputDecoration(
                  labelText: "Teléfono de contacto",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createAnnouncement,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Publicar anuncio"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
