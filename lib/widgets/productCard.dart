import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:huellas_salud_movil/models/products.dart';
import 'dart:convert';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 220,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Center(child: _buildProductImage(product)),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Text(
                  '\$${formatter.format(product.price)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

    Widget _buildProductImage(Product product) {
    if (product.mediaFile != null && product.mediaFile!.attachment.isNotEmpty) {
      final attach = product.mediaFile!.attachment;
      if (attach.startsWith('http://') || attach.startsWith('https://')) {
        return Image.network(
          attach,
          height: 130,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.image_not_supported,
            size: 60,
            color: Colors.grey,
          ),
        );
      }
      try {
        final bytes = base64Decode(attach);
        return Image.memory(
          bytes,
          height: 130,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return const Icon(
          Icons.image_not_supported,
          size: 60,
          color: Colors.grey,
        );
      }
    }
    return const Icon(Icons.image_not_supported, size: 60, color: Colors.grey);
  }
}

final formatter = NumberFormat.currency(
  locale: 'es_CO', // Español Colombia
  symbol: '', // Símbolo de peso
  decimalDigits: 0, // 0 si no quieres decimales
);
