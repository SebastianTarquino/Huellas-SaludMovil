import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/invoice.dart';

class FacturaService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.internalBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Factura>> fetchFacturas({int limit = 20, int offset = 0}) async {
    try {
      // Simulamos datos ya que no tenemos el endpoint real
      await Future.delayed(const Duration(seconds: 1));
      
      // Datos de ejemplo (simulando respuesta de API)
      final List<Factura> facturasEjemplo = List.generate(68, (index) {
        final id = 146 - index;
        final precios = [689000, 824500, 409200, 371600, 259300, 199000, 462200, 320000];
        return Factura(
          id: 'F-$id',
          numero: id,
          cliente: 'Cliente ${id % 5 == 0 ? 'Armando Puentes' : 'Nombre ${id % 10}'}',
          mascota: id % 5 == 0 ? 'Probable/Bravicio' : 'Mascota ${id % 10}',
          fecha: '${(id % 28) + 1}/01/2025',
          monto: precios[id % precios.length].toDouble(),
          estado: id % 5 == 0 ? 'Pagada' : (id % 5 == 1 ? 'Pendiente' : 'Cancelada'),
          items: [
            ItemFactura(descripcion: 'Consulta veterinaria general', cantidad: 1, precio: 530000),
            ItemFactura(descripcion: 'Nocera Folivalente', cantidad: 1, precio: 580000),
            ItemFactura(descripcion: 'Bravecio', cantidad: 1, precio: 120000),
            ItemFactura(descripcion: 'Pro Plan Adulto 3kg', cantidad: 1, precio: 85000),
            ItemFactura(descripcion: 'Juguete Kong', cantidad: 1, precio: 45000),
          ],
          envio: id % 3 == 0 ? 0 : 10000,
        );
      });

      return facturasEjemplo.sublist(offset, offset + limit > facturasEjemplo.length 
          ? facturasEjemplo.length 
          : offset + limit);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<Factura> fetchFacturaById(String id) async {
    try {
      // Simulamos la búsqueda de una factura específica
      await Future.delayed(const Duration(seconds: 1));
      
      final precios = [689000, 824500, 409200, 371600, 259300, 199000, 462200, 320000];
      final numero = int.parse(id.replaceAll('F-', ''));
      
      return Factura(
        id: id,
        numero: numero,
        cliente: 'Cliente ${numero % 5 == 0 ? 'Armando Puentes' : 'Nombre ${numero % 10}'}',
        mascota: numero % 5 == 0 ? 'Probable/Bravicio' : 'Mascota ${numero % 10}',
        fecha: '${(numero % 28) + 1}/01/2025',
        monto: precios[numero % precios.length].toDouble(),
        estado: numero % 5 == 0 ? 'Pagada' : (numero % 5 == 1 ? 'Pendiente' : 'Cancelada'),
        items: [
          ItemFactura(descripcion: 'Consulta veterinaria general', cantidad: 1, precio: 530000),
          ItemFactura(descripcion: 'Nocera Folivalente', cantidad: 1, precio: 580000),
          ItemFactura(descripcion: 'Bravecio', cantidad: 1, precio: 120000),
          ItemFactura(descripcion: 'Pro Plan Adulto 3kg', cantidad: 1, precio: 85000),
          ItemFactura(descripcion: 'Juguete Kong', cantidad: 1, precio: 45000),
        ],
        envio: numero % 3 == 0 ? 0 : 10000,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}