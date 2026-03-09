import 'package:flutter/material.dart';
import 'package:mobile_app/models/products.dart';
import 'package:mobile_app/models/sale.dart';


class SalesPage extends StatefulWidget {
  const SalesPage({super.key});
  @override
  State<SalesPage> createState() => _State();
}

class _State extends State<SalesPage> {
  final List<Sale> _allSales = getDummySales();
  final List<Products> _products = Products.getProducts();

  // Filters
  String _selectedProduct = 'All';
  String _selectedPeriod  = 'Past Year';

  final List<String> _periods = [
    'Past Week',
    'Past Month',
    'Past 3 Months',
    'Past 6 Months',
    'Past Year',
  ];

  List<Sale> get _filtered {
    final now = DateTime.now();

    // Time filter
    final Duration cutoff = switch (_selectedPeriod) {
      'Past Week'     => const Duration(days: 7),
      'Past Month'    => const Duration(days: 30),
      'Past 3 Months' => const Duration(days: 90),
      'Past 6 Months' => const Duration(days: 180),
      _               => const Duration(days: 365),
    };

    return _allSales.where((s) {
      final inPeriod = now.difference(s.date) <= cutoff;
      final matchProduct = _selectedProduct == 'All' || s.product.name == _selectedProduct;
      return inPeriod && matchProduct;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double get _totalRevenue =>
      _filtered.fold(0, (sum, s) => sum + s.total);

  int get _totalUnits =>
      _filtered.fold(0, (sum, s) => sum + s.quantity);

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final sales = _filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: Column(
        children: [

          // ── Filters ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                // Product filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedProduct,
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
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
                // Time filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: 'Period',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: _periods
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPeriod = v!),
                  ),
                ),
              ],
            ),
          ),

          // ── Summary cards ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _summaryCard('Total Revenue', '\$${_totalRevenue.toStringAsFixed(2)}'),
                const SizedBox(width: 12),
                _summaryCard('Units Sold', '$_totalUnits'),
                const SizedBox(width: 12),
                _summaryCard('Orders', '${sales.length}'),
              ],
            ),
          ),

          // ── Sales list ────────────────────────────────────
          Expanded(
            child: sales.isEmpty
                ? const Center(
                    child: Text('No sales found for this filter.',
                        style: TextStyle(color: Colors.white54)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: sales.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final s = sales[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF555555)),
                        ),
                        child: Row(
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                s.product.imageUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 48,
                                  height: 48,
                                  color: const Color(0xFF3A3A3A),
                                  child: const Icon(Icons.image_outlined,
                                      color: Colors.white38, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.product.name,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('Qty: ${s.quantity}  ·  ${_formatDate(s.date)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white54)),
                                ],
                              ),
                            ),
                            // Total
                            Text('\$${s.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.greenAccent)),
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

  Widget _summaryCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF555555)),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: Colors.white54),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
