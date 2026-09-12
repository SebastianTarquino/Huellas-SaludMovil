class Factura {
  final String id;
  final int numero;
  final String cliente;
  final String mascota;
  final String fecha;
  final double monto;
  final String estado;
  final List<ItemFactura> items;
  final int envio;

  Factura({
    required this.id,
    required this.numero,
    required this.cliente,
    required this.mascota,
    required this.fecha,
    required this.monto,
    required this.estado,
    required this.items,
    required this.envio,
  });

  factory Factura.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return Factura(
      id: data['id'] ?? '',
      numero: data['numero'] ?? 0,
      cliente: data['cliente'] ?? '',
      mascota: data['mascota'] ?? '',
      fecha: data['fecha'] ?? '',
      monto: (data['monto'] ?? 0).toDouble(),
      estado: data['estado'] ?? '',
      items: (data['items'] as List<dynamic>? ?? []).map((item) => ItemFactura.fromJson(item)).toList(),
      envio: data['envio'] ?? 0,
    );
  }
}

class ItemFactura {
  final String descripcion;
  final int cantidad;
  final double precio;

  ItemFactura({
    required this.descripcion,
    required this.cantidad,
    required this.precio,
  });

  factory ItemFactura.fromJson(Map<String, dynamic> json) {
    return ItemFactura(
      descripcion: json['descripcion'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      precio: (json['precio'] ?? 0).toDouble(),
    );
  }
}