import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/products.dart';

class ProductService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.internalBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Product>> fetchProducts({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get(
        'product/list-products',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data;

        // Mapear solo los datos que vienen en results sin hacer peticiones extra
        final List<Product> products = results.map((item) {
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

          return Product(
            idProduct: data['idProduct']
                .toString(), // convertimos a String por seguridad
            name: data['name'] ?? 'Sin nombre',
            category: data['category'],
            animalType: data['animalType'],
            description: data['description'],
            price: data['price'],
            mediaFile: mediaFile,
          );
        }).toList();

        return products;
      } else {
        throw Exception('Failed to load products');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<Product> fetchProductById(int id) async {
    try {
      final response = await _dio.get('products/$id'); // 👈 Ajusta el endpoint

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw Exception('Failed to load product');
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
