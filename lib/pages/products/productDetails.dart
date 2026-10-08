import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/products.dart';
import 'dart:convert';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final Function(Product)? onEdit;
  final Function(Product)? onDelete;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    double total = widget.product.price * quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          if (widget.onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar producto',
              onPressed: () {
                Navigator.pop(context);
                widget.onEdit!(widget.product);
              },
            ),
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Eliminar producto',
              onPressed: () {
                Navigator.pop(context);
                widget.onDelete!(widget.product);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildProductImage(widget.product),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).floatingActionButtonTheme.backgroundColor ?? const Color(0xFF7E57C2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "\$" + "${formatter.format(widget.product.price)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              widget.product.description.isNotEmpty ? widget.product.description : "Sin descripción disponible",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                    ),
                    Text("$quantity", style: const TextStyle(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
                Text(
                  "Total \$" + "${formatter.format(total)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E57C2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${widget.product.name} x$quantity agregado al carrito",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Agregar al carrito",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          product.mediaFile != null && product.mediaFile!.attachment.isNotEmpty
          ? _decodeImage(product.mediaFile!.attachment)
          : const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
    );
  }

  Widget _decodeImage(String base64String) {
    if (base64String.startsWith('http://') || base64String.startsWith('https://')) {
      return Image.network(
        base64String,
        height: 220,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.image_not_supported,
          size: 60,
          color: Colors.grey,
        ),
      );
    }
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(bytes, height: 220, fit: BoxFit.contain);
    } catch (e) {
      return const Icon(
        Icons.image_not_supported,
        size: 60,
        color: Colors.grey,
      );
    }
  }
}

final formatter = NumberFormat.currency(
  locale: 'es_CO',
  symbol: '',
  decimalDigits: 0,
);
