import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/products.dart';
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

  // ðŸ›¡ï¸ Rol de usuario
  String _userRole = 'CLIENTE';

  // ðŸ” Estado de BÃºsqueda y Filtros
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Todas';
  String _selectedAnimalType = 'Todos';
  String _selectedSort = 'Sin ordenar';

  // Productos de demostraciÃ³n completos para cada categorÃ­a y tipo de animal
  final List<Product> _defaultMockProducts = [
    // --- ALIMENTO ---
    Product(
      idProduct: 'mock-1',
      name: 'Purina Alpo 2Kg',
      category: 'Alimento',
      animalType: 'Perro',
      description: 'Alimento completo para perros adultos de todas las razas.',
      price: 15000,
      mediaFile: MediaFile(
        fileName: 'alpo.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-2',
      name: 'Agility Gold PequeÃ±os Adultos',
      category: 'Alimento',
      animalType: 'Perro',
      description: 'NutriciÃ³n de alta calidad para perros de razas pequeÃ±as.',
      price: 42000,
      mediaFile: MediaFile(
        fileName: 'agility.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1568640347023-a616a30bc3bd?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-3',
      name: 'Cat Chow Gatitos 1.5Kg',
      category: 'Alimento',
      animalType: 'Gato',
      description: 'FÃ³rmula nutritiva con DHA para el desarrollo saludable de gatitos.',
      price: 28000,
      mediaFile: MediaFile(
        fileName: 'catchow.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-4',
      name: 'Semillas Mixtas para Canarios 1Kg',
      category: 'Alimento',
      animalType: 'Aves',
      description: 'Mezcla balanceada de alpiste y semillas naturales para aves domÃ©sticas.',
      price: 12000,
      mediaFile: MediaFile(
        fileName: 'semillas.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400',
      ),
    ),

    // --- JUGUETES ---
    Product(
      idProduct: 'mock-5',
      name: 'Juguete Kong Classic Medium',
      category: 'Juguetes',
      animalType: 'Perro',
      description: 'Juguete de caucho sÃºper duradero para rellenar con snacks.',
      price: 45000,
      mediaFile: MediaFile(
        fileName: 'kong.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1535294435445-d7249524ef2e?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-6',
      name: 'Gimnasio Rascador para Gatos',
      category: 'Juguetes',
      animalType: 'Gato',
      description: 'Torre rascador multinivel con hamaca y juguetes colgantes.',
      price: 225000,
      mediaFile: MediaFile(
        fileName: 'gym_gato.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-7',
      name: 'Pelota Interactiva de Goma',
      category: 'Juguetes',
      animalType: 'Perro',
      description: 'Pelota de goma con textura estimulante para la salud dental.',
      price: 18000,
      mediaFile: MediaFile(
        fileName: 'pelota.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-7b',
      name: 'Varita Interactiva con Plumas',
      category: 'Juguetes',
      animalType: 'Gato',
      description: 'Juguete de caza interactivo con cascabel para felinos.',
      price: 14000,
      mediaFile: MediaFile(
        fileName: 'varita.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
      ),
    ),

    // --- MEDICINAS ---
    Product(
      idProduct: 'mock-8',
      name: 'Bravecto Antipulgas Canino 10-20kg',
      category: 'Medicinas',
      animalType: 'Perro',
      description: 'Comprimido masticable contra pulgas y garrapatas por 12 semanas.',
      price: 120000,
      mediaFile: MediaFile(
        fileName: 'bravecto.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-9',
      name: 'Antigulpas y garrapatas NexGard',
      category: 'Medicinas',
      animalType: 'Perro',
      description: 'Tableta masticable sabor a carne para protecciÃ³n de 30 dÃ­as.',
      price: 52000,
      mediaFile: MediaFile(
        fileName: 'nexgard.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-10',
      name: 'Pipeta Antipulgas Revolution Gatos',
      category: 'Medicinas',
      animalType: 'Gato',
      description: 'Tratamiento tÃ³pico seguro y eficaz contra parÃ¡sitos en gatos.',
      price: 48000,
      mediaFile: MediaFile(
        fileName: 'revolution.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-10b',
      name: 'MultivitamÃ­nico Canino en Jarabe',
      category: 'Medicinas',
      animalType: 'Perro',
      description: 'Suplemento nutricional con omega 3 y vitaminas A, D, E.',
      price: 35000,
      mediaFile: MediaFile(
        fileName: 'vitamina.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
      ),
    ),

    // --- ACCESORIOS ---
    Product(
      idProduct: 'mock-11',
      name: 'Collar Ajustable de Cuero Feroz',
      category: 'Accesorios',
      animalType: 'Perro',
      description: 'Collar de alta durabilidad con herrajes inoxidables.',
      price: 10000,
      mediaFile: MediaFile(
        fileName: 'collar.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-12',
      name: 'Comedero Doble Acero Inoxidable',
      category: 'Accesorios',
      animalType: 'Gato',
      description: 'Base antideslizante con platos desmontables fÃ¡ciles de lavar.',
      price: 22000,
      mediaFile: MediaFile(
        fileName: 'comedero.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-13',
      name: 'Jaula Espaciosa para Aves',
      category: 'Accesorios',
      animalType: 'Aves',
      description: 'Jaula metÃ¡lica resistente con comederos y columpios incluidos.',
      price: 110000,
      mediaFile: MediaFile(
        fileName: 'jaula.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-13b',
      name: 'Cama OrtopÃ©dica Acolchada',
      category: 'Accesorios',
      animalType: 'Perro',
      description: 'Cama de descanso ergonÃ³mica con espuma viscoelÃ¡stica lavable.',
      price: 85000,
      mediaFile: MediaFile(
        fileName: 'cama.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1541599540903-216a46ca1dc0?w=400',
      ),
    ),

    // --- HIGIENE ---
    Product(
      idProduct: 'mock-14',
      name: 'Arena para Gatos Aglomerante 5Kg',
      category: 'Higiene',
      animalType: 'Gato',
      description: 'Arena bentonita de alta absorciÃ³n con control de olores.',
      price: 25000,
      mediaFile: MediaFile(
        fileName: 'arena.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-15',
      name: 'ShampÃº Medicado HipoalergÃ©nico',
      category: 'Higiene',
      animalType: 'Perro',
      description: 'FÃ³rmula suave para pieles sensibles con PH neutro.',
      price: 32000,
      mediaFile: MediaFile(
        fileName: 'shampoo.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-16',
      name: 'Cepillo Quitapelos AutomÃ¡tico',
      category: 'Higiene',
      animalType: 'Gato',
      description: 'Cepillo de autolimpieza para remociÃ³n eficiente de pelo muerto.',
      price: 19000,
      mediaFile: MediaFile(
        fileName: 'cepillo.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
      ),
    ),
    Product(
      idProduct: 'mock-17',
      name: 'PaÃ±ales Desechables Caninos 10 Unidades',
      category: 'Higiene',
      animalType: 'Perro',
      description: 'PaÃ±ales ultra absorbentes con orificio para la cola.',
      price: 26000,
      mediaFile: MediaFile(
        fileName: 'panales.png',
        contentType: 'image/png',
        attachment: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400',
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('auth_user');
      if (userStr != null) {
        final parsed = jsonDecode(userStr);
        final userData = (parsed['data'] is Map) ? parsed['data'] : parsed;
        final role = (userData['role'] ?? 'CLIENTE').toString().toUpperCase().trim();
        setState(() {
          _userRole = role;
        });
      }
    } catch (e) {
      print("Error al verificar rol: $e");
    }
  }

  bool get _canCreateProduct =>
      _userRole == 'ADMIN' || _userRole == 'VETERINARIO';

  Future<void> _loadProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final customProducts = await _productService.getCustomProducts();
      final backendProducts = await _productService.fetchProducts(
        limit: _limit,
        offset: _offset,
      );

      final combinedList = <Product>[];
      combinedList.addAll(customProducts);

      if (backendProducts.isNotEmpty) {
        combinedList.addAll(backendProducts);
      } else {
        combinedList.addAll(_defaultMockProducts);
      }

      setState(() {
        final existingIds = <String>{};
        final filteredList = <Product>[];
        for (var p in combinedList) {
          if (!existingIds.contains(p.idProduct)) {
            existingIds.add(p.idProduct);
            filteredList.add(p);
          }
        }
        _products.clear();
        _products.addAll(filteredList);
        _hasMore = false;
        _isLoading = false;
      });
    } catch (e) {
      final customProducts = await _productService.getCustomProducts();
      setState(() {
        _products.clear();
        _products.addAll(customProducts);
        _products.addAll(_defaultMockProducts);
        _isLoading = false;
      });
    }
  }

  // Listas de categorÃ­as y tipos de animales disponibles
  List<String> get _availableCategories {
    final categoriesSet = <String>{'Todas', 'Alimento', 'Juguetes', 'Medicinas', 'Accesorios', 'Higiene'};
    for (var p in _products) {
      if (p.category.trim().isNotEmpty) {
        categoriesSet.add(p.category.trim());
      }
    }
    return categoriesSet.toList();
  }

  List<String> get _availableAnimalTypes {
    final animalSet = <String>{'Todos', 'Perro', 'Gato', 'Aves', 'Otros'};
    for (var p in _products) {
      if (p.animalType.trim().isNotEmpty) {
        animalSet.add(p.animalType.trim());
      }
    }
    return animalSet.toList();
  }

  // Filtrado de productos segÃºn bÃºsqueda y filtros aplicados
  List<Product> get _filteredProducts {
    return _products.where((product) {
      // 1. BÃºsqueda por texto
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatches = product.name.toLowerCase().contains(query);
        final descMatches = product.description.toLowerCase().contains(query);
        final catMatches = product.category.toLowerCase().contains(query);
        final animalMatches = product.animalType.toLowerCase().contains(query);
        if (!nameMatches && !descMatches && !catMatches && !animalMatches) {
          return false;
        }
      }

      // 2. Filtro de CategorÃ­a
      if (_selectedCategory != 'Todas') {
        final prodCat = product.category.toLowerCase().trim();
        final selCat = _selectedCategory.toLowerCase().trim();
        if (!prodCat.contains(selCat) && !selCat.contains(prodCat)) {
          return false;
        }
      }

      // 3. Filtro de Tipo de Animal
      if (_selectedAnimalType != 'Todos') {
        final prodAnimal = product.animalType.toLowerCase().trim();
        final selAnimal = _selectedAnimalType.toLowerCase().trim();
        if (!prodAnimal.contains(selAnimal) && !selAnimal.contains(prodAnimal)) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) {
        if (_selectedSort == 'Precio: Menor a Mayor') {
          return a.price.compareTo(b.price);
        } else if (_selectedSort == 'Precio: Mayor a Menor') {
          return b.price.compareTo(a.price);
        }
        return 0;
      });
  }

  bool get _hasActiveFilters =>
      _selectedCategory != 'Todas' ||
      _selectedAnimalType != 'Todos' ||
      _selectedSort != 'Sin ordenar';

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'Todas';
      _selectedAnimalType = 'Todos';
      _selectedSort = 'Sin ordenar';
    });
  }

  void _onProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product, onEdit: _showEditProductModal, onDelete: _confirmDeleteProduct)),
    );
  }

  // âž• MODAL PARA CREAR PRODUCTO (Solo Admin / Veterinario)
  void _showCreateProductModal() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Alimento';
    String selectedAnimal = 'Perro';
    String? selectedBase64Image;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF1E1E2C) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickProductImage() async {
              try {
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 600,
                  maxHeight: 600,
                  imageQuality: 80,
                );
                if (picked != null) {
                  final bytes = await picked.readAsBytes();
                  setModalState(() {
                    selectedBase64Image = base64Encode(bytes);
                  });
                }
              } catch (e) {
                print("Error al seleccionar imagen: $e");
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.add_shopping_cart, color: Color(0xFF7E57C2)),
                            const SizedBox(width: 8),
                            Text(
                              "Crear Producto",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Nombre del Producto
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Producto *',
                        prefixIcon: Icon(Icons.shopping_bag_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Precio ($)
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Precio (\$) *',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // CategorÃ­a
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon: Icon(Icons.category_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: ['Alimento', 'Juguetes', 'Medicinas', 'Accesorios', 'Higiene']
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Tipo de Animal
                    DropdownButtonFormField<String>(
                      value: selectedAnimal,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Animal',
                        prefixIcon: Icon(Icons.pets),
                        border: OutlineInputBorder(),
                      ),
                      items: ['Perro', 'Gato', 'Aves', 'Otros']
                          .map((animal) => DropdownMenuItem(value: animal, child: Text(animal)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedAnimal = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // DescripciÃ³n
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        prefixIcon: Icon(Icons.description_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // SelecciÃ³n de Imagen
                    InkWell(
                      onTap: pickProductImage,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.image, color: Color(0xFF7E57C2)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedBase64Image != null
                                    ? "Imagen cargada âœ“"
                                    : "Seleccionar Imagen de GalerÃ­a",
                                style: TextStyle(
                                  color: selectedBase64Image != null ? Colors.green : textColor,
                                  fontWeight: selectedBase64Image != null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // BotÃ³n Guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7E57C2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          "Guardar Producto",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final priceText = priceController.text.trim();
                          if (name.isEmpty || priceText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Completa el nombre y el precio del producto"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          final price = double.tryParse(priceText) ?? 0.0;
                          final newProduct = Product(
                            idProduct: 'prod-${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            category: selectedCategory,
                            animalType: selectedAnimal,
                            description: descriptionController.text.trim(),
                            price: price,
                            mediaFile: selectedBase64Image != null
                                ? MediaFile(
                                    fileName: 'image.png',
                                    contentType: 'image/png',
                                    attachment: selectedBase64Image!,
                                  )
                                : MediaFile(
                                    fileName: 'default.png',
                                    contentType: 'image/png',
                                    attachment: 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400',
                                  ),
                          );

                          // Persistir localmente en SharedPreferences para que no desaparezca jamÃ¡s al cambiar de pestaÃ±a
                          await _productService.saveCustomProduct(newProduct);

                          // Intentar enviar a backend (si existe endpoint)
                          await _productService.createProduct({
                            'name': name,
                            'category': selectedCategory,
                            'animalType': selectedAnimal,
                            'description': descriptionController.text.trim(),
                            'price': price,
                          });

                          setState(() {
                            _products.removeWhere((p) => p.idProduct == newProduct.idProduct);
                            _products.insert(0, newProduct);
                          });

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Â¡Producto '$name' creado exitosamente!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Modal de Filtros (Bottom Sheet) - SIN EMOJIS EN LOS CHIPS DE ANIMAL
  void _showFilterBottomSheet() {
    String tempCategory = _selectedCategory;
    String tempAnimal = _selectedAnimalType;
    String tempSort = _selectedSort;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF1E1E2C) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tune, color: Color(0xFF7E57C2)),
                          const SizedBox(width: 8),
                          Text(
                            "Filtros de BÃºsqueda",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // SecciÃ³n CategorÃ­a
                  Text(
                    "CategorÃ­a",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableCategories.map((cat) {
                      final isSelected = tempCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: const Color(0xFF7E57C2),
                        backgroundColor: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFF3F4F6),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              tempCategory = cat;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // SecciÃ³n Tipo de Animal (SIN EMOJIS)
                  Text(
                    "Tipo de Animal",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableAnimalTypes.map((animal) {
                      final isSelected = tempAnimal == animal;
                      return ChoiceChip(
                        label: Text(animal),
                        selected: isSelected,
                        selectedColor: const Color(0xFF7E57C2),
                        backgroundColor: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFF3F4F6),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              tempAnimal = animal;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // SecciÃ³n Ordenar por Precio
                  Text(
                    "Ordenar por Precio",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Sin ordenar', 'Precio: Menor a Mayor', 'Precio: Mayor a Menor'].map((sortOpt) {
                      final isSelected = tempSort == sortOpt;
                      return ChoiceChip(
                        label: Text(sortOpt),
                        selected: isSelected,
                        selectedColor: const Color(0xFF7E57C2),
                        backgroundColor: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFF3F4F6),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              tempSort = sortOpt;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Botones de acciÃ³n
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                          ),
                          onPressed: () {
                            setModalState(() {
                              tempCategory = 'Todas';
                              tempAnimal = 'Todos';
                              tempSort = 'Sin ordenar';
                            });
                          },
                          child: Text(
                            "Restablecer",
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7E57C2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedCategory = tempCategory;
                              _selectedAnimalType = tempAnimal;
                              _selectedSort = tempSort;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Aplicar Filtros",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchBg = isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF3F4F6);
    final inputColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final filterCount = (_selectedCategory != 'Todas' ? 1 : 0) +
        (_selectedAnimalType != 'Todos' ? 1 : 0) +
        (_selectedSort != 'Sin ordenar' ? 1 : 0);

    final filteredList = _filteredProducts;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ðŸ” BARRA DE BÃšSQUEDA
            Container(
              decoration: BoxDecoration(
                color: searchBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: inputColor, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Buscar',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // ðŸŽ›ï¸ FILTROS Y BOTÃ“N "CREAR PRODUCTO" (RESTRINGIDO A ADMIN Y VETERINARIO)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _showFilterBottomSheet,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 20,
                          color: filterCount > 0
                              ? const Color(0xFF7E57C2)
                              : (isDark ? Colors.grey[300] : Colors.black87),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Filtros",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: filterCount > 0
                                ? const Color(0xFF7E57C2)
                                : (isDark ? Colors.white : const Color(0xFF1F2937)),
                          ),
                        ),
                        if (filterCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF7E57C2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "$filterCount",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // âž• BOTÃ“N "CREAR PRODUCTO" (PestaÃ±a derecha, solo visible para ADMIN y VETERINARIO)
                if (_canCreateProduct)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E57C2),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1,
                    ),
                    onPressed: _showCreateProductModal,
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text(
                      "Crear Producto",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (_hasActiveFilters)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text(
                      "Limpiar todo",
                      style: TextStyle(color: Color(0xFF7E57C2), fontSize: 13),
                    ),
                  ),
              ],
            ),

            // Chips horizontales de filtros activos
            if (_hasActiveFilters) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedCategory != 'Todas')
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Chip(
                                label: Text("Cat: $_selectedCategory"),
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () {
                                  setState(() {
                                    _selectedCategory = 'Todas';
                                  });
                                },
                                backgroundColor: const Color(0xFF7E57C2).withOpacity(0.1),
                                side: BorderSide.none,
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7E57C2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (_selectedAnimalType != 'Todos')
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Chip(
                                label: Text("Animal: $_selectedAnimalType"),
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () {
                                  setState(() {
                                    _selectedAnimalType = 'Todos';
                                  });
                                },
                                backgroundColor: const Color(0xFF7E57C2).withOpacity(0.1),
                                side: BorderSide.none,
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7E57C2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (_selectedSort != 'Sin ordenar')
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Chip(
                                label: Text(_selectedSort),
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () {
                                  setState(() {
                                    _selectedSort = 'Sin ordenar';
                                  });
                                },
                                backgroundColor: const Color(0xFF7E57C2).withOpacity(0.1),
                                side: BorderSide.none,
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7E57C2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_canCreateProduct)
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text(
                        "Limpiar",
                        style: TextStyle(color: Color(0xFF7E57C2), fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),

            // ðŸ›’ LISTA O GRILLA DE PRODUCTOS
            Expanded(
              child: _products.isEmpty && _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: isDark ? Colors.grey[600] : Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No se encontraron productos",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Prueba cambiando la bÃºsqueda o los filtros",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              if (_hasActiveFilters || _searchQuery.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7E57C2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                      _clearFilters();
                                    });
                                  },
                                  icon: const Icon(Icons.refresh, color: Colors.white),
                                  label: const Text(
                                    "Limpiar bÃºsqueda y filtros",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ProductList(
                          products: filteredList,
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

  void _confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de que deseas eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await _productService.deleteProduct(product.idProduct);
              if (mounted) {
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto eliminado exitosamente')),
                  );
                  _loadProducts();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al eliminar el producto')),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditProductModal(Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toInt().toString());
    final descriptionController = TextEditingController(text: product.description);
    final imageUrlController = TextEditingController(
      text: product.mediaFile != null ? product.mediaFile!.attachment : '',
    );
    String selectedCategory = product.category.isNotEmpty ? product.category : 'Alimento';
    String selectedAnimalType = product.animalType.isNotEmpty ? product.animalType : 'Perro';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Editar Producto',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del producto',
                          prefixIcon: Icon(Icons.shopping_bag_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          prefixIcon: Icon(Icons.category_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: ['Alimento', 'Juguetes', 'Medicinas', 'Accesorios', 'Higiene']
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedCategory = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedAnimalType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Animal',
                          prefixIcon: Icon(Icons.pets),
                          border: OutlineInputBorder(),
                        ),
                        items: ['Perro', 'Gato', 'Aves', 'Otros']
                            .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedAnimalType = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Precio (\$)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          prefixIcon: Icon(Icons.description_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL de la imagen (opcional)',
                          prefixIcon: Icon(Icons.image_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7E57C2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (nameController.text.trim().isEmpty) return;
                                  setModalState(() => isSaving = true);

                                  final updateData = {
                                    'name': nameController.text.trim(),
                                    'category': selectedCategory,
                                    'animalType': selectedAnimalType,
                                    'price': double.tryParse(priceController.text) ?? product.price,
                                    'description': descriptionController.text.trim(),
                                    'imageUrl': imageUrlController.text.trim(),
                                    'mediaFile': imageUrlController.text.trim().isNotEmpty ? {
                                      'fileName': 'product.jpg',
                                      'contentType': 'image/jpeg',
                                      'attachment': imageUrlController.text.trim()
                                    } : null
                                  };

                                  final ok = await _productService.updateProduct(product.idProduct, updateData);
                                  if (mounted) {
                                    Navigator.pop(context);
                                    if (ok) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Producto actualizado exitosamente')),
                                      );
                                      _loadProducts();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Error al actualizar el producto')),
                                      );
                                    }
                                  }
                                },
                          child: isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

}
