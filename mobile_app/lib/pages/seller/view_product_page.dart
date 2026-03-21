// lib/pages/seller/view_product_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_app/models/products.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/style.dart';

class ViewProductPage extends StatefulWidget {
  final Products product;
  const ViewProductPage({super.key, required this.product});
  @override
  State<ViewProductPage> createState() => _State();
}

class _State extends State<ViewProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.product.name);
  late final _descCtrl =
      TextEditingController(text: widget.product.description);
  late final _priceCtrl = TextEditingController(
      text: widget.product.price.toStringAsFixed(2));

  late String? _selectedCategory = widget.product.category;
  PlatformFile? _imageFile;
  bool _editing = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.image, withData: true);
    if (result != null) setState(() => _imageFile = result.files.first);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.product.id == null) return;
    setState(() => _saving = true);

    try {
      final payload = {
        'name': _nameCtrl.text.trim(),
        'category': _selectedCategory,
        'description': _descCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text.trim()),
        if (_imageFile != null) 'image_url': _imageFile!.name,
      };

      final updated = await ApiService.instance
          .updateProduct(widget.product.id!, payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully.')),
      );
      setState(() => _editing = false);
      // Return updated product to caller
      Navigator.pop(context, updated);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        title: const Text('Delete Product',
            style: TextStyle(color: AppColors.textMain)),
        content: const Text(
            'Are you sure? This cannot be undone.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              await _delete();
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _delete() async {
    if (widget.product.id == null) return;
    try {
      await ApiService.instance.deleteProduct(widget.product.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted.')),
      );
      // Pass null to signal deletion to caller
      Navigator.pop(context, null);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        title: const Text('Product Details',
            style: TextStyle(color: AppColors.textMain)),
        actions: [
          if (!_editing) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.white70),
              onPressed: () => setState(() => _editing = true),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent),
              onPressed: _confirmDelete,
            ),
          ],
          if (_editing)
            TextButton(
              onPressed: () => setState(() => _editing = false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Image ────────────────────────────────────
              GestureDetector(
                onTap: _editing ? _pickImage : null,
                child: Container(
                  height: 200, width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: _buildImageContent(),
                ),
              ),

              const SizedBox(height: 20),

              // ── Name ─────────────────────────────────────
              _label('Product Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                enabled: _editing,
                style: const TextStyle(
                    color: AppColors.textMain, fontSize: 14),
                cursorColor: AppColors.primary,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: _inputDeco(),
              ),

              const SizedBox(height: 14),

              // ── Category ─────────────────────────────────
              _label('Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: AppColors.surfaceColor,
                style: const TextStyle(
                    color: AppColors.textMain, fontSize: 14),
                decoration: _inputDeco(),
                onChanged: _editing
                    ? (v) => setState(() => _selectedCategory = v)
                    : null,
                items: Products.categories
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Please select a category'
                    : null,
              ),

              const SizedBox(height: 14),

              // ── Description ──────────────────────────────
              _label('Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                enabled: _editing,
                maxLines: 3,
                style: const TextStyle(
                    color: AppColors.textMain, fontSize: 14),
                cursorColor: AppColors.primary,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: _inputDeco(),
              ),

              const SizedBox(height: 14),

              // ── Price ────────────────────────────────────
              _label('Price'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceCtrl,
                enabled: _editing,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d*')),
                ],
                style: const TextStyle(
                    color: AppColors.textMain, fontSize: 14),
                cursorColor: AppColors.primary,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v.trim()) == null)
                    return 'Enter a valid price';
                  return null;
                },
                decoration: _inputDeco(prefix: '\$'),
              ),

              const SizedBox(height: 14),

              // ── Status badge ─────────────────────────────
              Row(
                children: [
                  _label('Status'),
                  const SizedBox(width: 12),
                  _StatusBadge(isActive: widget.product.isActive),
                ],
              ),

              const SizedBox(height: 28),

              // ── Save ─────────────────────────────────────
              if (_editing)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black))
                        : const Text('Save Changes',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_imageFile?.bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(_imageFile!.bytes!, fit: BoxFit.cover),
      );
    }
    final url = widget.product.imageUrl;
    if (url.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(url, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder()),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined,
              color: Colors.white38, size: 40),
          if (_editing) ...[
            const SizedBox(height: 8),
            const Text('Tap to change image',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ],
      );

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 13, color: Colors.white70));

  InputDecoration _inputDeco({String? prefix}) => InputDecoration(
        prefixText: prefix,
        prefixStyle: const TextStyle(color: AppColors.textMain),
        filled: true,
        fillColor: AppColors.surfaceColor,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white24)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white24)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
                color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
                color: Colors.redAccent, width: 1.5)),
      );
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.15)
              : Colors.redAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.redAccent,
            width: 0.8,
          ),
        ),
        child: Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.primary : Colors.redAccent,
          ),
        ),
      );
}
