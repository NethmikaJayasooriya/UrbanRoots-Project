// lib/pages/seller/sales_page.dart

import 'package:flutter/material.dart';
import 'package:mobile_app/models/sale.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/style.dart';

class SalesPage extends StatefulWidget {
  // TODO: replace with real seller ID from auth session
  final String sellerId;
  const SalesPage({
    super.key,
    this.sellerId = 'PLACEHOLDER_SELLER_ID',
  });
  @override
  State<SalesPage> createState() => _State();
}

class _State extends State<SalesPage> {
  List<Sale> _allSales = [];
  bool _loading = true;
  String? _error;

  String _selectedProduct = 'All';
  String _selectedPeriod  = 'Past Year';

  final List<String> _periods = [
    'Past Week',
    'Past Month',
    'Past 3 Months',
    'Past 6 Months',
    'Past Year',
  ];

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  // ── Data ──────────────────────────────────────────────────

  Future<void> _loadSales() async {
    setState(() { _loading = true; _error = null; });
    try {
      final now = DateTime.now();
      // Always fetch the widest window (1 year) and filter locally
      final from = now.subtract(const Duration(days: 365));
      final sales = await ApiService.getSales(
        widget.sellerId,
        from: from,
        to: now,
      );
      if (mounted) {
        setState(() { _allSales = sales; _loading = false; });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    }
  }

  // ── Computed ──────────────────────────────────────────────

  /// Unique product names across all loaded sales
  List<String> get _productNames {
    final names = _allSales.map((s) => s.productName).toSet().toList();
    names.sort();
    return names;
  }

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
      final inPeriod = now.difference(s.saleDate) <= cutoff;
      final matchProduct =
          _selectedProduct == 'All' || s.productName == _selectedProduct;
      return inPeriod && matchProduct;
    }).toList()
      ..sort((a, b) => b.saleDate.compareTo(a.saleDate));
  }

  double get _totalRevenue =>
      _filtered.fold(0.0, (sum, s) => sum + s.total);

  int get _totalUnits =>
      _filtered.fold(0, (sum, s) => sum + s.quantity);

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        title: const Text('Sales',
            style: TextStyle(color: AppColors.textMain)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMain),
            onPressed: _loadSales,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _loadSales)
              : Column(
                  children: [
                    _buildFilters(),
                    _buildSummaryCards(),
                    Expanded(child: _buildList()),
                  ],
                ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surfaceColor,
      child: Row(
        children: [
          // Product filter
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedProduct,
              dropdownColor: AppColors.surfaceColor,
              style: const TextStyle(
                  color: AppColors.textMain, fontSize: 13),
              isDense: true,
              decoration: _filterDeco('Product'),
              items: [
                const DropdownMenuItem(value: 'All', child: Text('All')),
                ..._productNames.map((name) => DropdownMenuItem(
                      value: name,
                      child: Text(name,
                          overflow: TextOverflow.ellipsis),
                    )),
              ],
              onChanged: (v) =>
                  setState(() => _selectedProduct = v!),
            ),
          ),
          const SizedBox(width: 12),
          // Period filter
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPeriod,
              dropdownColor: AppColors.surfaceColor,
              style: const TextStyle(
                  color: AppColors.textMain, fontSize: 13),
              isDense: true,
              decoration: _filterDeco('Period'),
              items: _periods
                  .map((p) =>
                      DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedPeriod = v!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final sales = _filtered;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _SummaryCard(
              label: 'Total Revenue',
              value: '\$${_totalRevenue.toStringAsFixed(2)}'),
          const SizedBox(width: 12),
          _SummaryCard(label: 'Units Sold', value: '$_totalUnits'),
          const SizedBox(width: 12),
          _SummaryCard(label: 'Orders', value: '${sales.length}'),
        ],
      ),
    );
  }

  Widget _buildList() {
    final sales = _filtered;
    if (sales.isEmpty) {
      return const Center(
        child: Text('No sales found for this filter.',
            style: TextStyle(color: Colors.white54)),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadSales,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: sales.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _SaleTile(
          sale: sales[i],
          formatDate: _formatDate,
        ),
      ),
    );
  }

  InputDecoration _filterDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white24)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
                color: AppColors.primary, width: 1.5)),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
}

// ── Sale tile ──────────────────────────────────────────────────
class _SaleTile extends StatelessWidget {
  final Sale sale;
  final String Function(DateTime) formatDate;
  const _SaleTile({required this.sale, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final s = sale;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: s.productImageUrl.startsWith('http')
                ? Image.network(s.productImageUrl,
                    width: 48, height: 48, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgPlaceholder())
                : _imgPlaceholder(),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.productName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain)),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${s.quantity}  ·  ${formatDate(s.saleDate)}',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.white54),
                ),
                Text(
                  '@\$${s.unitPrice.toStringAsFixed(2)} each',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ),
          // Total
          Text(
            '\$${s.total.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        width: 48, height: 48, color: Colors.white10,
        child: const Icon(Icons.image_outlined,
            color: Colors.white38, size: 20),
      );
}

// ── Summary card ───────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain)),
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

// ── Error view ─────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined,
                  color: Colors.white38, size: 48),
              const SizedBox(height: 16),
              Text(message,
                  style: const TextStyle(color: Colors.white54),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary)),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
}

