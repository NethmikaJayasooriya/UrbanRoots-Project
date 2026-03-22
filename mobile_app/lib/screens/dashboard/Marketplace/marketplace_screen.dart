import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'shopping_Cart.dart';
import 'product_detail_screen.dart';
import 'order_history_screen.dart';
import 'marketplace_theme.dart';
import 'marketplace_api.dart';

// ─── Product ──────────────────────────────────────────────────────────────────
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String? description;
  final String? imageUrl;
  final IconData placeholderIcon;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description,
    this.imageUrl,
    this.placeholderIcon = Icons.eco_rounded,
  });
}

// ─── MarketplaceScreen1 ───────────────────────────────────────────────────────
class MarketplaceScreen1 extends StatefulWidget {
  const MarketplaceScreen1({super.key});

  @override
  State<MarketplaceScreen1> createState() => _MarketplaceScreen1State();
}

class _MarketplaceScreen1State extends State<MarketplaceScreen1> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Seeds', 'Leafy Greens', 'Indoor', 'Tools'];

  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final productsData = await MarketplaceApi.fetchProducts();
      final List<Product> loadedProducts = [];
      for (var p in productsData) {
        loadedProducts.add(Product(
          id: p['id'].toString(),
          name: p['name'],
          category: p['category'],
          price: double.tryParse(p['price']?.toString() ?? '0') ?? 0.0,
          description: p['description'],
          imageUrl: p['imageUrl'] ?? p['image_url'],
          placeholderIcon: _getIconForCategory(p['category']),
        ));
      }
      if (mounted) {
        setState(() {
          _products = loadedProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('Error fetching products: $e');
      }
    }
  }

  IconData _getIconForCategory(String category) {
    if (category == 'Seeds') return Icons.spa_rounded;
    if (category == 'Indoor') return Icons.local_florist_rounded;
    if (category == 'Leafy Greens') return Icons.grass_rounded;
    if (category == 'Tools') return Icons.hardware_rounded;
    return Icons.eco_rounded;
  }

  List<Product> get _filteredProducts {
    return _products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Scaffold(
      backgroundColor: MarketplaceTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('UrbanRoots Market',
            style: TextStyle(fontWeight: FontWeight.w800, color: MarketplaceTheme.textWhite, letterSpacing: 1.2)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
            },
            icon: const Icon(Icons.receipt_long_rounded, color: MarketplaceTheme.primaryGreen),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Shopping_Cart()),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined, color: MarketplaceTheme.primaryGreen),
              ),
              if (cart.totalCount > 0)
                Positioned(
                  right: 6,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: MarketplaceTheme.lightGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: MarketplaceTheme.lightGreen.withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                    ),
                    child: Text(
                      '${cart.totalCount}',
                      style: const TextStyle(color: MarketplaceTheme.darkGreen, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: MarketplaceTheme.glassBox(radius: 12),
                child: TextField(
                  style: const TextStyle(color: MarketplaceTheme.textWhite),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search seeds, tools, plants...',
                    hintStyle: const TextStyle(color: MarketplaceTheme.textGray),
                    prefixIcon: const Icon(Icons.search, color: MarketplaceTheme.primaryGreen),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? MarketplaceTheme.primaryGreen : MarketplaceTheme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? MarketplaceTheme.primaryGreen : MarketplaceTheme.primaryGreen.withOpacity(0.3),
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: MarketplaceTheme.primaryGreen.withOpacity(0.4), blurRadius: 8)]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? MarketplaceTheme.darkGreen : MarketplaceTheme.textWhite,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Product Grid
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: MarketplaceTheme.primaryGreen))
                  : _filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                            'No products found.',
                            style: TextStyle(color: MarketplaceTheme.textGray, fontSize: 16),
                          ),
                        )
                  : RefreshIndicator(
                      color: MarketplaceTheme.primaryGreen,
                      onRefresh: _loadProducts,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) => _buildProductCard(context, _filteredProducts[index], index),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, int index) {
    // Increase duration slightly for subsequent items to create a cascading effect
    final int baseDuration = 400;
    final int staggeredDuration = baseDuration + (index * 80);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: staggeredDuration),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
          );
        },
        child: Container(
          decoration: MarketplaceTheme.glassBox(radius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Image area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: MarketplaceTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Hero(
                        tag: 'product-image-${product.name}',
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [MarketplaceTheme.lightGreen, MarketplaceTheme.primaryGreen],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Icon(product.placeholderIcon, size: 54, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [MarketplaceTheme.lightGreen, MarketplaceTheme.primaryGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Icon(product.placeholderIcon, size: 54, color: Colors.white),
                        ),
                      ),
              ),
            ),
            // Details area
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    style: const TextStyle(fontSize: 11, color: MarketplaceTheme.textGray),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs. ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: MarketplaceTheme.lightGreen, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MarketplaceTheme.primaryGreen.withOpacity(0.2),
                        foregroundColor: MarketplaceTheme.primaryGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: MarketplaceTheme.primaryGreen.withOpacity(0.5)),
                        ),
                      ),
                      onPressed: () {
                        context.read<CartModel>().addItem(
                          CartItem(
                            name: product.name,
                            category: product.category,
                            price: product.price,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart', style: const TextStyle(color: MarketplaceTheme.darkGreen, fontWeight: FontWeight.bold)),
                            duration: const Duration(seconds: 1),
                            backgroundColor: MarketplaceTheme.lightGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Add to Cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}