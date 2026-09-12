import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import '../../services/invoices_services.dart';
import './detail_invoice.dart';

class HistorialFacturasScreen extends StatefulWidget {
  const HistorialFacturasScreen({super.key});

  @override
  _HistorialFacturasScreenState createState() => _HistorialFacturasScreenState();
}

class _HistorialFacturasScreenState extends State<HistorialFacturasScreen> {
  final FacturaService _facturaService = FacturaService();
  final List<Factura> _facturas = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFacturas();
  }

  Future<void> _loadFacturas() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newFacturas = await _facturaService.fetchFacturas(limit: _limit, offset: _offset);
      
      setState(() {
        if (newFacturas.isEmpty) {
          _hasMore = false;
        } else {
          final existingIds = _facturas.map((f) => f.id).toSet();
          final filtered = newFacturas.where((f) => !existingIds.contains(f.id)).toList();
          _facturas.addAll(filtered);
          _offset += _limit;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  List<Factura> _filterFacturas() {
    if (_searchController.text.isEmpty) {
      return _facturas;
    }
   
    final query = _searchController.text.toLowerCase();
    return _facturas.where((factura) {
      return factura.id.toLowerCase().contains(query) ||
          factura.cliente.toLowerCase().contains(query) ||
          factura.mascota.toLowerCase().contains(query) ||
          factura.numero.toString().contains(query);
    }).toList();
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

  Widget _buildFacturaCard(BuildContext context, Factura factura) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleFacturaScreen(factura: factura),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.receipt, color: Colors.purple),
              ),
              SizedBox(width: 16),
             
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Factura #${factura.numero}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text('Cliente: ${factura.cliente}'),
                    Text('Fecha: ${factura.fecha}'),
                  ],
                ),
              ),
             
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${_formatPrice(factura.monto)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getColorByEstado(factura.estado).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      factura.estado,
                      style: TextStyle(
                        color: _getColorByEstado(factura.estado),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    if (totalPages <= 1) return SizedBox.shrink();
   
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
          ),
         
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$_currentPage / $totalPages'),
          ),
         
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredFacturas = _filterFacturas();
    final totalPages = (filteredFacturas.length / _limit).ceil();
    final startIndex = (_currentPage - 1) * _limit;
    final endIndex = startIndex + _limit;
    final currentFacturas = filteredFacturas.sublist(
        startIndex, endIndex > filteredFacturas.length ? filteredFacturas.length : endIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text('Facturas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _currentPage = 1;
                });
              },
            ),
          ),
         
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historial de Facturas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_facturas.length} facturas',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
         
          SizedBox(height: 10),
         
          Expanded(
            child: ListView.builder(
              itemCount: currentFacturas.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < currentFacturas.length) {
                  return _buildFacturaCard(context, currentFacturas[index]);
                } else {
                  _loadFacturas();
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
         
          _buildPagination(totalPages),
        ],
      ),
    );
  }
}