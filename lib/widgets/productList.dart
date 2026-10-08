import 'package:flutter/material.dart';
import '../models/products.dart';
import 'productCard.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductTap;
  final Function(Product)? onEdit;
  final Function(Product)? onDelete;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  const ProductList({
    super.key,
    required this.products,
    required this.onProductTap,
    this.onEdit,
    this.onDelete,
    this.isLoading = false,
    this.hasMore = true,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (onLoadMore != null &&
            !isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          onLoadMore!();
        }
        return false;
      },
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: products.length + (isLoading && hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == products.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => onProductTap(product),
            onEdit: onEdit,
            onDelete: onDelete,
          );
        },
      ),
    );
  }
}
