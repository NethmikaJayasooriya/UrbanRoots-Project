// lib/pages/seller/seller_products_page.dart

import 'package:flutter/material.dart';
import 'package:mobile_app/models/products.dart';
import 'package:mobile_app/pages/seller/add_product_page.dart';
import 'package:mobile_app/pages/seller/view_product_page.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/style.dart';

class SellerProductsPage extends StatefulWidget {
  // TODO: replace with real seller ID from auth session
  final String sellerId;
  const SellerProductsPage({
    super.key,
    this.sellerId = 'PLACEHOLDER_SELLER_ID',
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
          await ApiService.instance.getProducts(widget.sellerId);
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
          await ApiService.instance.toggleProductActive(product.id!);
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
      await ApiService.instance.deleteProduct(product.id!);
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
      color: AppColors.primary,
      onRefresh: _loadProducts,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _ProductTile(
          product: filtered[i],
          onEdit: () => _openEdit(filtered[i]),
          onToggle: () => _toggleActive(filtered[i]),
          onDelete: () => _confirmDelete(filtered[i]),
        ),
      ),
    );
  }
}

// ── Product tile ───────────────────────────────────────────────
class _ProductTile extends StatelessWidget {
  final Products product;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;
    return AnimatedOpacity(
      opacity: p.isActive ? 1.0 : 0.55,
      duration: const Duration(milliseconds: 250),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: _ProductImage(url: p.imageUrl),
          title: Row(
            children: [
              Expanded(
                child: Text(p.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain)),
              ),
              _StatusBadge(isActive: p.isActive),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 3),
              Text(p.category,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.white38)),
              const SizedBox(height: 2),
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
                      color: AppColors.primary)),
            ],
          ),
          trailing: _ActionMenu(
            isActive: p.isActive,
            onEdit: onEdit,
            onToggle: onToggle,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String url;
  const _ProductImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final isNetwork = url.startsWith('http');
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: isNetwork
          ? Image.network(url,
              width: 56, height: 56, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder())
          : Image.asset(url,
              width: 56, height: 56, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder()),
    );
  }

  Widget _placeholder() => Container(
        width: 56, height: 56, color: Colors.white10,
        child: const Icon(Icons.image_outlined, color: Colors.white38),
      );
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
            ? AppColors.primary.withOpacity(0.12)
            : Colors.redAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.primary : Colors.redAccent,
          width: 0.6,
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10,
          color: isActive ? AppColors.primary : Colors.redAccent,
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
      icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
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
