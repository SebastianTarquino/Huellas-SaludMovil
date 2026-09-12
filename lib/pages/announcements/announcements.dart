import '../../widgets/phone_input_field.dart';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void dispose() {
    _descriptionController.dispose();
    _cellPhoneController.dispose();
    super.dispose();
  }

  // Seleccionar imagen
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

  // Mostrar imagen seleccionada o placeholder
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

  // Crear anuncio y subir imagen
  Future<void> _createAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String nameUserCreated = "Usuario";
      String emailUserCreated = "user@huellassalud.com";
      String roleUserCreated = "CLIENTE";

      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('auth_user');

      if (userStr != null) {
        try {
          final parsed = jsonDecode(userStr);
          final userData = (parsed['data'] is Map) ? parsed['data'] : parsed;
          final name = userData['name'] ?? '';
          final lastName = userData['lastName'] ?? '';
          if (name.toString().isNotEmpty) {
            nameUserCreated = "$name $lastName".trim();
          }
          if (userData['email'] != null) {
            emailUserCreated = userData['email'].toString();
          }
          if (userData['role'] != null) {
            roleUserCreated = userData['role'].toString();
          }
        } catch (e) {
          print("Error al leer auth_user: $e");
        }
      }

      print("Creando anuncio para: $nameUserCreated ($emailUserCreated)");

      final id = await _announcementService.createAnnouncement(
        description: _descriptionController.text.trim(),
        cellPhone: _cellPhoneController.text.trim(),
        nameUserCreated: nameUserCreated,
        emailUserCreated: emailUserCreated,
        roleUserCreated: roleUserCreated,
      );

      if (id != null) {
        if (!kIsWeb && _selectedImage != null) {
          await _announcementService.uploadAnnouncementImage(
            announcementId: id,
            imageFile: _selectedImage!,
          );
        } else if (kIsWeb && _webImageBytes != null) {
          await _announcementService.uploadAnnouncementImageWeb(
            announcementId: id,
            bytes: _webImageBytes!,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Anuncio publicado exitosamente!"),
              backgroundColor: Colors.purple,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print("Error al crear anuncio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al crear el anuncio"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear anuncio"),
        centerTitle: true,
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
                    value == null || value.trim().isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 16),
              PhoneInputField(
                controller: _cellPhoneController,
                labelText: "Teléfono de contacto",
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
