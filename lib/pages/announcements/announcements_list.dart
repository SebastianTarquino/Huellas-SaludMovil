import 'announcements.dart';
import 'announcement_detail.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:huellas_salud_movil/services/announcement_services.dart';
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

  Widget _buildImage(Map<String, dynamic> ann) {
    final String? announcementId = ann["idAnnouncement"]?.toString();
    final mediaFile = ann["mediaFile"];

    if (mediaFile != null && mediaFile is Map) {
      final String? attach = mediaFile["attachment"]?.toString();
      if (attach != null && attach.isNotEmpty) {
        if (attach.startsWith('http://') || attach.startsWith('https://')) {
          return Image.network(
            attach,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 190,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/img/images/placeholder.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 190,
            ),
          );
        }
        try {
          String cleanBase64 = attach;
          if (cleanBase64.contains(',')) {
            cleanBase64 = cleanBase64.split(',').last;
          }
          final bytes = base64Decode(cleanBase64.trim());
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 190,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/img/images/placeholder.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 190,
            ),
          );
        } catch (e) {
          print("Error al decodificar base64 de mediaFile: $e");
        }
      }
    }

    if (announcementId != null && announcementId.isNotEmpty) {
      final imageUrl =
          "${ApiConfig.internalBaseUrl}avatar-user/announcement/$announcementId?v=${DateTime.now().millisecondsSinceEpoch}";

      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 190,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/img/images/placeholder.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 190,
          );
        },
      );
    }

    return Image.asset(
      'assets/img/images/placeholder.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 190,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final titleTextColor = isDark ? Colors.white : const Color(0xFF2D1537);
    final subtitleTextColor = isDark ? const Color(0xFFB0BEC5) : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF5F3F9),
      floatingActionButton: FloatingActionButton(
        heroTag: 'announcement_list_add_fab',
        backgroundColor: const Color(0xFF7E57C2),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnnouncementPage(),
            ),
          );
          if (result == true) {
            setState(() {
              _announcementsFuture = _announcementService.listAnnouncements();
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _announcementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF9575CD)));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los anuncios.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay anuncios disponibles.'));
          }

          final announcements = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final ann = announcements[index];
                            return InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementDetailScreen(announcement: ann),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      _announcementsFuture = _announcementService.listAnnouncements();
                    });
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.4) : Colors.purple.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFEDE7F6),
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(ann),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ann["description"] ?? "Sin descripción",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: titleTextColor,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2A2640) : const Color(0xFFEDE7F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone, size: 16, color: Color(0xFF9575CD)),
                                    const SizedBox(width: 6),
                                    Text(
                                      ann["cellPhone"] ?? "No disponible",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFFD1C4E9) : const Color(0xFF673AB7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 16, color: Color(0xFF9575CD)),
                              const SizedBox(width: 4),
                              Text(
                                "Publicado por: ${ann["nameUserCreated"] ?? "Desconocido"}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subtitleTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
