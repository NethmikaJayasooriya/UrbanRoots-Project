import 'package:flutter/material.dart';

class SellerPage extends StatelessWidget {
  const SellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Profile Summary ───────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF555555)),
              ),
              child: Row(
                children: [
                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 64,
                      height: 64,
                      color: const Color(0xFF3A3A3A),
                      child: const Icon(Icons.storefront_outlined,
                          color: Colors.white38, size: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name & rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('GreenLeaf Co.',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        const Text('hello@greenleaf.com',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white54)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            const Text('4.8',
                                style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: Colors.greenAccent, width: 0.5),
                              ),
                              child: const Text('Verified',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.greenAccent)),
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

            // ── Navigation Links ──────────────────────────
            const Text('Manage',
                style: TextStyle(fontSize: 13, color: Colors.white54)),
            const SizedBox(height: 10),

            _navTile(
              context,
              icon: Icons.inventory_2_outlined,
              label: 'My Products',
              subtitle: 'View, edit or delete products',
              onTap: () {
                // Navigator.push to SellerProductsPage
              },
            ),
            _navTile(
              context,
              icon: Icons.add_box_outlined,
              label: 'Add Product',
              subtitle: 'List a new product',
              onTap: () {
                // Navigator.push to AddProductPage
              },
            ),
            _navTile(
              context,
              icon: Icons.bar_chart_outlined,
              label: 'Sales',
              subtitle: 'View your sales history',
              onTap: () {
                // Navigator.push to SalesPage
              },
            ),
            _navTile(
              context,
              icon: Icons.manage_accounts_outlined,
              label: 'Update Details',
              subtitle: 'Edit business info and payment details',
              onTap: () {
                // Navigator.push to UpdateSellerDetailsPage
              },
            ),
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
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: Icon(icon, color: Colors.white70, size: 22),
          title: Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.white38)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white38),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Color(0xFF3A3A3A)),
      ],
    );
  }
}
