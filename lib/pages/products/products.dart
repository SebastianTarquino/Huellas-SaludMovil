import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/products.dart';
import '../../widgets/appbar.dart';
import '../../services/products_services.dart';
import '../../widgets/productList.dart';
import '../products/productDetails.dart';

class ProductHomePage extends StatefulWidget {
  const ProductHomePage({super.key});

  @override
  State<ProductHomePage> createState() => _ProductHomePageState();
}

class _ProductHomePageState extends State<ProductHomePage> {
  final ProductService _productService = ProductService();
  final List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newProducts = await _productService.fetchProducts(
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        if (newProducts.isEmpty) {
          _hasMore = false;
        } else {
          final existingIds = _products.map((p) => p.idProduct).toSet();
          final filtered =
              newProducts.where((p) => !existingIds.contains(p.idProduct)).toList();
          _products.addAll(filtered);
          _offset += _limit;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar(e.toString());
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product),),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _products.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: ProductList(
                      products: _products,
                      onProductTap: _onProductTap,
                      isLoading: _isLoading,
                      onLoadMore: _loadProducts,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
