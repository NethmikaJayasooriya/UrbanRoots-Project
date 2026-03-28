// lib/pages/seller/seller_page.dart

import 'package:flutter/material.dart';
import 'package:mobile_app/models/seller.dart';
import 'package:mobile_app/screens/dashboard/UserProfile/add_product_page.dart';
import 'package:mobile_app/screens/dashboard/UserProfile/sales_page.dart';
import 'package:mobile_app/screens/dashboard/UserProfile/seller_products_page.dart';
import 'package:mobile_app/screens/dashboard/UserProfile/update_seller_details.dart';
import 'package:mobile_app/shared/api/api_service.dart';
import 'package:mobile_app/style.dart';

class SellerPage extends StatefulWidget {
  final Seller seller;
  const SellerPage({super.key, required this.seller});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  late Seller _seller;
  bool _refreshingRating = true;

  @override
  void initState() {
    super.initState();
    _seller = widget.seller;
    _refreshSellerRating();
  }

  /// Fetches fresh seller data from the backend so the rating shown
  /// is always computed from live customer reviews.
  Future<void> _refreshSellerRating() async {
    try {
      final data = await ApiService.getSeller();
      if (!mounted || data == null) return;
      setState(() {
        _seller = Seller.fromJson(data);
        _refreshingRating = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _refreshingRating = false);
    }
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
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
                            _refreshingRating
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.amber,
                                    ),
                                  )
                                : Text(
                                    _seller.rating > 0
                                        ? _seller.rating.toStringAsFixed(1)
                                        : 'No reviews yet',
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

