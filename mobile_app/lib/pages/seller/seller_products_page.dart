import 'package:flutter/material.dart';
import 'package:mobile_app/models/products.dart';
import 'package:mobile_app/pages/seller/add_product_page.dart';
import 'package:mobile_app/pages/seller/view_product_page.dart';
import 'package:mobile_app/style.dart';

class SellerProductsPage extends StatefulWidget {
  const SellerProductsPage({super.key});
  @override
  State<SellerProductsPage> createState() => _State();
}

class _State extends State<SellerProductsPage> {
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
            child: Text('Delete',
                style: TextStyle(color: AppColors.error)),
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddProductPage())),
              icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
              label: const Text('Add',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: _products.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 48, color: AppColors.textFaint),
                  const SizedBox(height: 12),
                  const Text('No products yet.',
                      style: TextStyle(
                          color: AppColors.textdim,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Tap Add to list your first product.',
                      style: TextStyle(
                          color: AppColors.textFaint, fontSize: 13)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              itemCount: _products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final p = _products[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ViewProductPage(product: p))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSm),
                            child: Image.asset(
                              p.imageUrl,
                              width: 58,
                              height: 58,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 58,
                                height: 58,
                                color: AppColors.surfaceAlt,
                                child: const Icon(Icons.image_outlined,
                                    color: AppColors.textFaint, size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMain)),
                                const SizedBox(height: 4),
                                Text(p.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textdim)),
                                const SizedBox(height: 6),
                                Text('\$${p.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary)),
                              ],
                            ),
                          ),

                          // Actions
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20, color: AppColors.textLight),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ViewProductPage(product: p))),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    size: 20, color: AppColors.error),
                                onPressed: () => _confirmDelete(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}