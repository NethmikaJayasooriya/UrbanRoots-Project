// lib/pages/seller/seller_products_page.dart

import 'package:flutter/material.dart';
import 'package:mobile_app/models/products.dart';
import 'package:mobile_app/screens/dashboard/UserProfile/add_product_page.dart';
import 'package:mobile_app/screens/dashboard/UserProfile/view_product_page.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/style.dart';
import 'package:mobile_app/screens/dashboard/Marketplace/marketplace_theme.dart';

class SellerProductsPage extends StatefulWidget {
  final String sellerId;
  const SellerProductsPage({
    super.key,
    required this.sellerId,
  });
  @override
  State<SellerProductsPage> createState() => _State();
}

class _State extends State<SellerProductsPage> {
  List<Products> _products = [];
  bool _loading = true;
  String? _error;
  String _filterStatus = 'All'; // 'All' | 'Active' | 'Inactive'

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // ── Data ──────────────────────────────────────────────────

  Future<void> _loadProducts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final products =
          await ApiService.getProducts(widget.sellerId);
      if (mounted) setState(() { _products = products; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    }
  }

  List<Products> get _filtered {
    if (_filterStatus == 'Active') return _products.where((p) => p.isActive).toList();
    if (_filterStatus == 'Inactive') return _products.where((p) => !p.isActive).toList();
    return _products;
  }

  // ── Actions ───────────────────────────────────────────────

  Future<void> _toggleActive(Products product) async {
    if (product.id == null) return;
    try {
      final updated =
          await ApiService.toggleProductActive(product.id!);
      setState(() {
        final i = _products.indexWhere((p) => p.id == updated.id);
        if (i != -1) _products[i] = updated;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          '"${updated.name}" marked as '
          '${updated.isActive ? "active" : "inactive"}.',
        ),
        duration: const Duration(seconds: 2),
      ));
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  void _confirmDelete(Products product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        title: const Text('Delete Product',
            style: TextStyle(color: AppColors.textMain)),
        content: Text(
          'Delete "${product.name}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(Products product) async {
    if (product.id == null) return;
    try {
      await ApiService.deleteProduct(product.id!);
      setState(() => _products.removeWhere((p) => p.id == product.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${product.name}" deleted.')),
      );
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _openEdit(Products product) async {
    final updated = await Navigator.push<Products>(
      context,
      MaterialPageRoute(
          builder: (_) => ViewProductPage(product: product)),
    );
    // If ViewProductPage returns an updated product, refresh the list
    if (updated != null) {
      setState(() {
        final i = _products.indexWhere((p) => p.id == updated.id);
        if (i != -1) _products[i] = updated;
      });
    }
  }

  Future<void> _openAdd() async {
    final created = await Navigator.push<Products>(
      context,
      MaterialPageRoute(
          builder: (_) => AddProductPage(sellerId: widget.sellerId)),
    );
    if (created != null) {
      setState(() => _products.insert(0, created));
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        title: const Text('My Products',
            style: TextStyle(color: AppColors.textMain)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMain),
            tooltip: 'Refresh',
            onPressed: _loadProducts,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textMain),
            tooltip: 'Add Product',
            onPressed: _openAdd,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _loadProducts)
              : Column(
                  children: [
                    // ── Filter chips ───────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children:
                            ['All', 'Active', 'Inactive'].map((label) {
                          final selected = _filterStatus == label;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(label),
                              selected: selected,
                              onSelected: (_) =>
                                  setState(() => _filterStatus = label),
                              selectedColor:
                                  AppColors.primary.withOpacity(0.2),
                              backgroundColor: AppColors.surfaceColor,
                              side: BorderSide(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.white24,
                              ),
                              labelStyle: TextStyle(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.white54,
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_filtered.length} product'
                          '${_filtered.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white38),
                        ),
                      ),
                    ),
                    // ── List ────────────────────────────────────
                    Expanded(child: _buildList()),
                  ],
                ),
    );
  }

  Widget _buildList() {
    final filtered = _filtered;
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          _filterStatus == 'All'
              ? 'No products yet. Tap + to add one.'
              : 'No $_filterStatus products.',
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }
    return RefreshIndicator(
      color: MarketplaceTheme.primaryGreen,
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: filtered.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) => _buildProductCard(context, filtered[index], index),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Products product, int index) {
    final int baseDuration = 400;
    final int staggeredDuration = baseDuration + (index * 80);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: staggeredDuration),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _openEdit(product),
        child: Container(
          decoration: MarketplaceTheme.glassBox(radius: 16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Area
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: MarketplaceTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: _buildImage(product.imageUrl!),
                            )
                          : const Center(
                              child: Icon(Icons.eco_rounded, size: 54, color: MarketplaceTheme.primaryGreen),
                            ),
                    ),
                  ),
                  // Details Area
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: MarketplaceTheme.textWhite),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w900, color: MarketplaceTheme.primaryGreen, fontSize: 13),
                            ),
                            _StatusBadge(isActive: product.isActive),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Floating Action Menu Overlay
              Positioned(
                top: 4, right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: _ActionMenu(
                    isActive: product.isActive,
                    onEdit: () => _openEdit(product),
                    onToggle: () => _toggleActive(product),
                    onDelete: () => _confirmDelete(product),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.eco_rounded, color: MarketplaceTheme.primaryGreen));
    }
    return Image.asset(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.eco_rounded, color: MarketplaceTheme.primaryGreen));
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? MarketplaceTheme.primaryGreen.withOpacity(0.12)
            : Colors.redAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? MarketplaceTheme.primaryGreen : Colors.redAccent,
          width: 0.6,
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isActive ? MarketplaceTheme.primaryGreen : Colors.redAccent,
        ),
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ActionMenu({
    required this.isActive,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.surfaceColor,
      icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
      onSelected: (v) {
        if (v == 'edit') onEdit();
        if (v == 'toggle') onToggle();
        if (v == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 16, color: Colors.white70),
            SizedBox(width: 10),
            Text('Edit', style: TextStyle(color: AppColors.textMain)),
          ]),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(children: [
            Icon(
              isActive
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 16,
              color: Colors.white70,
            ),
            const SizedBox(width: 10),
            Text(
              isActive ? 'Mark as Inactive' : 'Mark as Active',
              style: const TextStyle(color: AppColors.textMain),
            ),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ]),
        ),
      ],
    );
  }
}

// ── Error view ─────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
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
}



