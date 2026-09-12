import 'package:flutter/material.dart';
import 'package:huellas_salud_movil/pages/announcements/announcements_list.dart';
import 'package:huellas_salud_movil/pages/announcements/announcements.dart';
import 'package:huellas_salud_movil/pages/products/productDetails.dart';
import 'package:huellas_salud_movil/pages/products/products.dart';
import 'package:huellas_salud_movil/pages/settings/settings.dart';
import 'package:huellas_salud_movil/pages/notifications/notifications.dart';
import '../../widgets/appbar.dart';
import '../../widgets/navigation_buttom.dart';
import '../user/user.dart';
import '../auth/login.dart';
import '../../models/products.dart';
import '../../services/products_services.dart';
import '../../widgets/productCard.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String password;

  const HomeScreen({super.key, required this.username, required this.password});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(
        username: widget.username,
        onGoToProducts: () {
          setState(() {
            _currentIndex = 2;
          });
          _pageController.jumpToPage(2);
        },
      ),
      const AnnouncementListPage(),
      const ProductHomePage(),
      UserScreen(username: widget.username, password: widget.password),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getTitle(),
        showBackButton: false,
      ),
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),

      // 🔹 Solo mostrar el botón flotante en la pestaña de “Anuncios”
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              backgroundColor: Colors.purple,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading:
                                const Icon(Icons.campaign, color: Colors.purple),
                            title: const Text('Crear anuncio'),
                            onTap: () {
                              Navigator.pop(context); // Cierra el modal
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AnnouncementPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                );
              },
            )
          : null,

      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Anuncios';
      case 2:
        return 'Productos';
      case 3:
        return 'Perfil';
      default:
        return '';
    }
  }
}

class HomeContent extends StatefulWidget {
  final String username;
  final VoidCallback? onGoToProducts;

  const HomeContent({super.key, required this.username, this.onGoToProducts});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final newProducts = await _productService.fetchProducts(
        limit: 20,
        offset: 0,
      );
      setState(() {
        newProducts.shuffle();
        _products = newProducts.take(4).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al cargar productos: $e')));
    }
  }

  void _onProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner principal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/img/images/banner.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
              width: double.infinity,
              height: 220,
            ),
          ),
          const SizedBox(height: 15),

          // Categorías
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Categorías",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 105,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _CategoryItem("assets/img/images/comida.png", "Comida"),
                _CategoryItem("assets/img/images/accesorios.png", "Accesorios"),
                _CategoryItem("assets/img/images/limpieza.png", "Limpieza"),
                _CategoryItem("assets/img/images/salud.png", "Salud"),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Productos
          InkWell(
            onTap: widget.onGoToProducts,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Productos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Lista de productos
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
                  ? const Text("No hay productos disponibles.")
                  : SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ProductCard(
                              product: product,
                              onTap: () => _onProductTap(product),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String imagePath;
  final String title;

  const _CategoryItem(this.imagePath, this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.grey[200],
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
