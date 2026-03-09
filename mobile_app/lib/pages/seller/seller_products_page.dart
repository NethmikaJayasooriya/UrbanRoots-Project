import 'package:flutter/material.dart';
import 'package:mobile_app/models/products.dart';


class SellerProductsPage extends StatefulWidget {
  const SellerProductsPage({super.key});
  @override
  State<SellerProductsPage> createState() => _State();
}

class _State extends State<SellerProductsPage> {
  // Replace with your actual data source
  final List<Products> _products = Products.getProducts();

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${_products[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _products.removeAt(index));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product deleted.')),
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
            onPressed: () {
              // Navigate to AddProductPage
            },
          ),
        ],
      ),
      body: _products.isEmpty
          ? const Center(
              child: Text('No products yet. Tap + to add one.',
                  style: TextStyle(color: Colors.white54)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = _products[index];
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF555555)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        p.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 56,
                          height: 56,
                          color: const Color(0xFF3A3A3A),
                          child: const Icon(Icons.image_outlined,
                              color: Colors.white38),
                        ),
                      ),
                    ),
                    title: Text(p.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(p.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white54)),
                        const SizedBox(height: 4),
                        Text('\$${p.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.greenAccent)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              size: 20, color: Colors.white54),
                          onPressed: () {
                            // Navigate to ViewProductPage(product: p)
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 20, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
