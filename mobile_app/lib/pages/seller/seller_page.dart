import 'package:flutter/material.dart';
import 'package:mobile_app/pages/seller/add_product_page.dart';
import 'package:mobile_app/pages/seller/sales_page.dart';
import 'package:mobile_app/pages/seller/seller_products_page.dart';
import 'package:mobile_app/pages/seller/update_seller_details.dart';
import 'package:mobile_app/style.dart';

class SellerPage extends StatelessWidget {
  const SellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Hero / Profile Banner ─────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.surfaceColor,
                border: Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App label
                  Row(
                    children: [
                      const Icon(Icons.eco, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Urban Roots',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Profile row
                  Row(
                    children: [
                      // Logo avatar
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryMuted,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GreenLeaf Co.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'hello@greenleaf.com',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textdim,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Rating
                                const Icon(Icons.star_rounded,
                                    color: AppColors.primary, size: 15),
                                const SizedBox(width: 3),
                                const Text('4.8',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMain)),
                                const SizedBox(width: 10),
                                // Verified badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryMuted,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppColors.primary, width: 0.8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.verified_outlined,
                                          color: AppColors.primary, size: 11),
                                      SizedBox(width: 3),
                                      Text(
                                        'Verified',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Manage Section ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'MANAGE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.8,
                ),
              ),
            ),

            // Nav tiles
            _navTile(context,
                icon: Icons.inventory_2_outlined,
                label: 'My Products',
                subtitle: 'View, edit or delete products',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const SellerProductsPage()))),
            _navTile(context,
                icon: Icons.add_box_outlined,
                label: 'Add Product',
                subtitle: 'List a new product',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const AddProductPage()))),
            _navTile(context,
                icon: Icons.bar_chart_outlined,
                label: 'Sales',
                subtitle: 'View your sales history',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SalesPage()))),
            _navTile(context,
                icon: Icons.manage_accounts_outlined,
                label: 'Update Details',
                subtitle: 'Edit business info and payment details',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const UpdateSellerDetailsPage()))),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMain)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textdim)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.textFaint, size: 20),
              ],
            ),
          ),
        ),
        const Divider(height: 1, indent: 74, color: AppColors.border),
      ],
    );
  }
}