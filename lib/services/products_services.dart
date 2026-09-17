import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/products.dart';

class ProductService {
  static const String _customProductsKey = 'user_custom_products_list';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.internalBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Product>> getCustomProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_customProductsKey);
      if (str != null && str.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(str);
        return jsonList
            .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      print("Error al cargar productos personalizados: $e");
    }
    return [];
  }

  Future<void> saveCustomProduct(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getCustomProducts();
      currentList.removeWhere((p) => p.idProduct == product.idProduct);
      currentList.insert(0, product);

      final jsonString = jsonEncode(currentList.map((p) => p.toJson()).toList());
      await prefs.setString(_customProductsKey, jsonString);
    } catch (e) {
      print("Error al guardar producto personalizado: $e");
    }
  }

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
            category: data['category'] ?? '',
            animalType: data['animalType'] ?? '',
            description: data['description'] ?? '',
            price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
            mediaFile: mediaFile,
          );
        }).toList();

        return products;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Product> fetchProductById(int id) async {
    try {
      final response = await _dio.get('products/$id');

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

  Future<bool> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post(
        'product/create-product',
        data: productData,
        options: Options(validateStatus: (status) => true),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}



