import 'package:flutter/material.dart';
import '../models/products.dart';
import 'productCard.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductTap;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  const ProductList({
    super.key,
    required this.products,
    required this.onProductTap,
    this.isLoading = false,
    this.hasMore = true,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Detecta cuando se llega al final del scroll y carga más
        if (onLoadMore != null &&
            !isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          onLoadMore!();
        }
        return false;
      },
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // dos columnas
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75, // ajusta la proporción según ProductCard
              ),
              padding: const EdgeInsets.all(8),
              itemCount: products.length + (isLoading && hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Muestra indicador de carga si estamos cargando más
                if (index == products.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () => onProductTap(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
