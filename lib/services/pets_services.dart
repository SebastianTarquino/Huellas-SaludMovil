import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/pets.dart';

class PetService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.internalBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Pet>> fetchPet({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get(
        'pet/list-pets',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data;

        // Mapear solo los datos que vienen en results sin hacer peticiones extra
        final List<Pet> pets = results.map((item) {
          final data = item['data'] ?? {};

          MediaFile? mediaFile;
          if (data['mediaFile'] != null) {
            final mf = data['mediaFile'];
            mediaFile = MediaFile(
              fileName: mf['fileName'] ?? '',
              contentType: mf['contentType'] ?? '',
              attachment: mf['attachment'] ?? '',
            );
          }

          return Pet(
            idPet: data['idPet']
                .toString(), // convertimos a String por seguridad
            name: data['name'] ?? 'Sin nombre',
            species: data['species'],
            sex: data['sex'],
            age: data['age'],
            mediaFile: mediaFile,
          );
        }).toList();

        return pets;
      } else {
        throw Exception('Failed to load pets');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<Pet> fetchProductById(int id) async {
    try {
      final response = await _dio.get('pet/$id'); // 👈 Ajusta el endpoint

      if (response.statusCode == 200) {
        return Pet.fromJson(response.data);
      } else {
        throw Exception('Failed to load pet');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
