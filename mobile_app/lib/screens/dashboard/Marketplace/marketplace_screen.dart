// marketplace_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'shopping_Cart.dart';
import 'product_detail_screen.dart';

// Represents an item available in the marketplace
class Product {
  final String name;
  final String category;
  final double price;
  final String? description;
  final String? imageUrl;

  const Product({
    required this.name,
    required this.category,
    required this.price,
    this.description, 
    this.imageUrl,    
  });
}

// ─── MarketplaceScreen1 ───────────────────────────────────────────────────────
class MarketplaceScreen1 extends StatelessWidget {
  const MarketplaceScreen1({super.key});

  // Product catalogue — description field is optional, can be filled in later
  static const List<Product> _products = [
    Product(
      name: 'Green Chilli Seeds',
      category: 'Kitchen Essentials',
      price: 150.00,
    ),
    Product(
      name: 'Basil Plant',
      category: 'Indoor',
      price: 320.00,
    ),
    Product(
      name: 'Spinach Seeds',
      category: 'Leafy Greens',
      price: 95.00,
    ),
    Product(
      name: 'Garden Trowel',
      category: 'Tools',
      price: 450.00,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // watch() subscribes to CartModel — rebuilds this widget when cart changes
    // so the badge count in the AppBar stays live
    final cart = context.watch<CartModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('UrbanRoots Market',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Shopping_Cart()),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              // Cart badge — only shown when there are items in the cart
              if (cart.totalCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.totalCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar — still visual only; wire up controller for live filtering
            TextField(
              decoration: InputDecoration(
                hintText: 'Search seeds, tools, plants...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Category chips
            const Text('Categories',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['All', 'Seeds', 'Leafy Greens', 'Indoor']
                    .map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                              label: Text(cat), selected: cat == 'All'),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Product grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) =>
                  _buildProductCard(context, _products[index]),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a tappable product card displaying the item's details and add-to-cart button.
  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      // Navigates to the product detail screen when the card is tapped
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            // FIX: Added the missing BoxShadow constructor here
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image area — green background with eco icon placeholder
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15)),
                ),
                child: const Center(
                  child: Icon(Icons.eco, size: 50, color: Colors.green),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),

                  // Category label
                  Text(product.category,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),

                  // Price
                  Text(
                    'Rs. ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),

                  // Add to cart functionality
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
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
                            content: Text('${product.name} added to cart'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text('Add to Cart',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}