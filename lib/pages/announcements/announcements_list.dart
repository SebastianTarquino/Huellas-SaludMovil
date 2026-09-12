import 'package:flutter/material.dart';
import 'package:huellas_salud_movil/services/announcement_services.dart';
import 'package:huellas_salud_movil/models/announcement.dart';
import '../../config/api_config.dart';

class AnnouncementListPage extends StatefulWidget {
  const AnnouncementListPage({Key? key}) : super(key: key);

  @override
  State<AnnouncementListPage> createState() => _AnnouncementListPageState();
}

class _AnnouncementListPageState extends State<AnnouncementListPage> {
  final AnnouncementService _announcementService = AnnouncementService();
  late Future<List<Map<String, dynamic>>> _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _announcementsFuture = _announcementService.listAnnouncements();
  }

  // 🖼️ Mostrar imagen del anuncio desde el backend o placeholder
  Widget _buildImage(String? announcementId) {
    if (announcementId == null || announcementId.isEmpty) {
      return Image.asset(
        'assets/img/images/placeholder.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: 180,
      );
    }

    final imageUrl =
        "${ApiConfig.internalBaseUrl}avatar-user/Announcement/$announcementId";

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 180,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/img/images/placeholder.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: 180,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _announcementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los anuncios.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay anuncios disponibles.'));
          }

          final announcements = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final ann = announcements[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(ann["idAnnouncement"]),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ann["description"] ?? "Sin descripción",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 18, color: Colors.purple),
                              const SizedBox(width: 6),
                              Text(
                                ann["cellPhone"] ?? "No disponible",
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Publicado por: ${ann["nameUserCreated"] ?? "Desconocido"}",
                            style: const TextStyle(fontSize: 13, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
