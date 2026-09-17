import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:huellas_salud_movil/models/products.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Subtítulo / Categoría
    String categoryText = product.category.trim();
    if (categoryText.isEmpty) {
      categoryText = product.animalType.trim().isNotEmpty ? product.animalType.trim() : 'Producto';
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFF0F0F5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼️ Contenedor de la Imagen
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildProductImage(product),
                  ),
                ),
                const SizedBox(height: 10),

                // 🏷️ Badge de Categoría
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF332946) : const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    categoryText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFD1C4E9) : const Color(0xFF7E57C2),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),

                // 📝 Nombre del Producto
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),

                // 💰 Precio
                Text(
                  '\$${formatter.format(product.price)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
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
      final attach = product.mediaFile!.attachment.trim();
      if (attach.startsWith('http://') || attach.startsWith('https://')) {
        return Image.network(
          attach,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 110,
          errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
        );
      }
      try {
        final bytes = base64Decode(attach);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 110,
          errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
        );
      } catch (e) {
        return _buildFallbackIcon();
      }
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: const Color(0xFFF3E5F5),
      child: const Center(
        child: Icon(
          Icons.pets,
          size: 40,
          color: Color(0xFF7E57C2),
        ),
      ),
    );
  }
}

final formatter = NumberFormat.currency(
  locale: 'es_CO', // Español Colombia
  symbol: '',
  decimalDigits: 0,
);
