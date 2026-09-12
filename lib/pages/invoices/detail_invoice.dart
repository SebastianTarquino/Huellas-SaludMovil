import 'package:flutter/material.dart';
import '../../models/invoice.dart';

class DetalleFacturaScreen extends StatelessWidget {
  final Factura factura;

  const DetalleFacturaScreen({Key? key, required this.factura}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iva = factura.monto * 0.19;
    final subtotal = factura.monto - iva - factura.envio;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Factura'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Factura #${factura.numero}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
           
            _buildInfoRow('Fecha:', factura.fecha),
            _buildInfoRow('Cliente:', factura.cliente),
            _buildInfoRow('Mascota:', factura.mascota),
           
            Divider(height: 30),
           
            Text('Productos/Servicios:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
           
            ...factura.items.map((item) => _buildItemRow(item)).toList(),
           
            Divider(height: 30),
           
            _buildTotalRow('Subtotal', subtotal),
            _buildTotalRow('Envío', factura.envio.toDouble(), isFree: factura.envio == 0),
            _buildTotalRow('IVA (19%)', iva),
            SizedBox(height: 10),
            _buildTotalRow('TOTAL', factura.monto, isTotal: true),
           
            SizedBox(height: 30),
           
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getColorByEstado(factura.estado).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Estado: ${factura.estado}',
                  style: TextStyle(
                    color: _getColorByEstado(factura.estado),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildItemRow(ItemFactura item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(item.descripcion),
          ),
          Expanded(
            flex: 1,
            child: Text('${item.cantidad}', textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${_formatPrice(item.precio)}',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, {bool isFree = false, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            isFree ? 'Gratis' : '\$${_formatPrice(value)}',
            style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Color _getColorByEstado(String estado) {
    switch (estado) {
      case 'Pagada':
        return Colors.green;
      case 'Pendiente':
        return Colors.orange;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}