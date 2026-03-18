import 'package:flutter/material.dart';
import 'package:mobile_app/models/products.dart';
import 'package:mobile_app/models/sale.dart';
import 'package:mobile_app/style.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});
  @override
  State<SalesPage> createState() => _State();
}

class _State extends State<SalesPage> {
  final List<Sale> _allSales = getDummySales();
  final List<Products> _products = Products.getProducts();

  String _selectedProduct = 'All';
  String _selectedPeriod  = 'Past Year';

  final List<String> _periods = [
    'Past Week', 'Past Month', 'Past 3 Months', 'Past 6 Months', 'Past Year',
  ];

  List<Sale> get _filtered {
    final now = DateTime.now();
    final Duration cutoff = switch (_selectedPeriod) {
      'Past Week'     => const Duration(days: 7),
      'Past Month'    => const Duration(days: 30),
      'Past 3 Months' => const Duration(days: 90),
      'Past 6 Months' => const Duration(days: 180),
      _               => const Duration(days: 365),
    };
    return _allSales.where((s) {
      return now.difference(s.date) <= cutoff &&
          (_selectedProduct == 'All' || s.product.name == _selectedProduct);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double get _totalRevenue => _filtered.fold(0, (s, e) => s + e.total);
  int    get _totalUnits   => _filtered.fold(0, (s, e) => s + e.quantity);

  String _formatDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final sales = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: Column(
        children: [

          // ── Filters ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceColor,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedProduct,
                    dropdownColor: AppColors.surfaceColor,
                    style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                    decoration: const InputDecoration(labelText: 'Product'),
                    items: [
                      const DropdownMenuItem(value: 'All', child: Text('All')),
                      ..._products.map((p) => DropdownMenuItem(
                            value: p.name,
                            child: Text(p.name, overflow: TextOverflow.ellipsis),
                          )),
                    ],
                    onChanged: (v) => setState(() => _selectedProduct = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedPeriod,
                    dropdownColor: AppColors.surfaceColor,
                    style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                    decoration: const InputDecoration(labelText: 'Period'),
                    items: _periods.map((p) =>
                        DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (v) => setState(() => _selectedPeriod = v!),
                  ),
                ),
              ],
            ),
          ),

          // ── Summary cards ─────────────────────────────────────
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Row(
              children: [
                _summaryCard('Revenue', '\$${_totalRevenue.toStringAsFixed(2)}',
                    Icons.attach_money),
                const SizedBox(width: 10),
                _summaryCard('Units Sold', '$_totalUnits',
                    Icons.shopping_bag_outlined),
                const SizedBox(width: 10),
                _summaryCard('Orders', '${sales.length}',
                    Icons.receipt_long_outlined),
              ],
            ),
          ),

          // ── Sales list ────────────────────────────────────────
          Expanded(
            child: sales.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bar_chart_outlined,
                            size: 48, color: AppColors.textFaint),
                        const SizedBox(height: 12),
                        const Text('No sales found.',
                            style: TextStyle(
                                color: AppColors.textdim,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('Try adjusting your filters.',
                            style: TextStyle(
                                color: AppColors.textFaint, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: sales.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final s = sales[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSm),
                              child: Image.asset(
                                s.product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 50,
                                  height: 50,
                                  color: AppColors.surfaceAlt,
                                  child: const Icon(Icons.image_outlined,
                                      color: AppColors.textFaint, size: 22),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.product.name,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textMain)),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Qty: ${s.quantity}  ·  ${_formatDate(s.date)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textdim)),
                                ],
                              ),
                            ),
                            Text('\$${s.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain)),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textdim),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}