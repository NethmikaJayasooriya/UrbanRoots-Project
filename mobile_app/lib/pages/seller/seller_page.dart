// lib/pages/seller/seller_page.dart

import 'package:flutter/material.dart';
import 'package:mobile_app/models/seller.dart';
import 'package:mobile_app/pages/seller/add_product_page.dart';
import 'package:mobile_app/pages/seller/sales_page.dart';
import 'package:mobile_app/pages/seller/seller_products_page.dart';
import 'package:mobile_app/pages/seller/update_seller_details.dart';
import 'package:mobile_app/style.dart';

class SellerPage extends StatefulWidget {
  final Seller seller;
  const SellerPage({super.key, required this.seller});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  late Seller _seller;

  @override
  void initState() {
    super.initState();
    _seller = widget.seller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Seller Dashboard',
          style: TextStyle(color: AppColors.textMain),
        ),
        // TODO: auth developer adds sign-out button here
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Profile Summary ──────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _seller.logoUrl != null &&
                            _seller.logoUrl!.startsWith('http')
                        ? Image.network(
                            _seller.logoUrl!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _logoPlaceholder(),
                          )
                        : _logoPlaceholder(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _seller.brandName ?? 'My Store',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _seller.businessEmail ?? '',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white54),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _seller.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMain),
                            ),
                            const SizedBox(width: 8),
                            if (_seller.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: AppColors.primary,
                                      width: 0.6),
                                ),
                                child: const Text(
                                  'Verified',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Manage',
              style: TextStyle(fontSize: 13, color: Colors.white54),
            ),
            const SizedBox(height: 10),

            _navTile(
              context,
              icon: Icons.inventory_2_outlined,
              label: 'My Products',
              subtitle: 'View, edit or delete products',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SellerProductsPage(sellerId: _seller.id),
                ),
              ),
            ),
            _navTile(
              context,
              icon: Icons.add_box_outlined,
              label: 'Add Product',
              subtitle: 'List a new product',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddProductPage(sellerId: _seller.id),
                ),
              ),
            ),
            _navTile(
              context,
              icon: Icons.bar_chart_outlined,
              label: 'Sales',
              subtitle: 'View your sales history',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SalesPage(sellerId: _seller.id),
                ),
              ),
            ),
            _navTile(
              context,
              icon: Icons.manage_accounts_outlined,
              label: 'Update Details',
              subtitle: 'Edit business info and payment details',
              onTap: () async {
                final updated = await Navigator.push<Seller>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        UpdateSellerDetailsPage(seller: _seller),
                  ),
                );
                // If seller updated their details, reflect on dashboard
                if (updated != null) {
                  setState(() => _seller = updated);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoPlaceholder() => Container(
        width: 64,
        height: 64,
        color: Colors.white10,
        child: const Icon(Icons.storefront_outlined,
            color: Colors.white38, size: 32),
      );

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: Icon(icon, color: Colors.white70, size: 22),
          title: Text(
            label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMain),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.white38),
          ),
          trailing:
              const Icon(Icons.chevron_right, color: Colors.white38),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Colors.white12),
      ],
    );
  }
}
