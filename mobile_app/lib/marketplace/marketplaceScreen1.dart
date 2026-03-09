import 'package:flutter/material.dart';

// FIX 1: Use forward slashes and ensure this points to the correct file where ShoppingCart is defined
// If ShoppingCart is in the same folder:
// import 'shopping_cart.dart'; 
// Or if using the package name:
import 'package:mobile_app/marketplace/shoppingCart.dart';

class MarketplaceScreen1 extends StatelessWidget {
  const MarketplaceScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UrbanRoots Market', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  // FIX 2: Removed 'const' because ShoppingCart might not have a const constructor
                  // or the compiler can't find the class due to the bad import.
                  builder: (context) => ShoppingCart(), 
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search seeds, tools, plants...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['All', 'Seeds', 'Leafy Greens', 'Indoor'].map((cat) => 
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(label: Text(cat), selected: cat == 'All'),
                  )
                ).toList(),
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => _buildProductCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: const Center(child: Icon(Icons.eco, size: 50, color: Colors.green)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Green Chilli Seeds', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Kitchen Essentials', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 5),
                const Text('Rs. 150.00', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Placeholder for ShoppingCart - ensure this is defined or imported correctly
class ShoppingCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Cart")));
  }
}