import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_app/models/products.dart';
import 'package:mobile_app/style.dart';


class ViewProductPage extends StatefulWidget {
  final Products product;
  const ViewProductPage({super.key, required this.product});
  @override
  State<ViewProductPage> createState() => _State();
}

class _State extends State<ViewProductPage> {
  final _formKey   = GlobalKey<FormState>();
  late final _nameCtrl  = TextEditingController(text: widget.product.name);
  late final _descCtrl  = TextEditingController(text: widget.product.description);
  late final _priceCtrl = TextEditingController(text: widget.product.price.toStringAsFixed(2));

  PlatformFile? _imageFile;
  bool _editing = false;
  bool _loading = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) setState(() => _imageFile = result.files.first);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() { _loading = false; _editing = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product updated successfully.')),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product deleted.')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _editing = true),
            ),
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _confirmDelete,
            ),
          if (_editing)
            TextButton(
              onPressed: () => setState(() => _editing = false),
              child: const Text('Cancel'),
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

              // ── Product Image ──────────────────────────────
              GestureDetector(
                onTap: _editing ? _pickImage : null,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _imageFile?.bytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          child: Image.memory(_imageFile!.bytes!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_outlined,
                                color: AppColors.textFaint, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              widget.product.imageUrl,
                              style: const TextStyle(
                                  color: AppColors.textFaint, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            if (_editing) ...[
                              const SizedBox(height: 8),
                              const Text('Tap to change image',
                                  style: TextStyle(
                                      color: AppColors.textdim, fontSize: 12)),
                            ],
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Product Name ───────────────────────────────
              const Text('Product Name',
                  style: TextStyle(fontSize: 13, color: AppColors.textLight)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                enabled: _editing,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),

              const SizedBox(height: 14),

              // ── Description ────────────────────────────────
              const Text('Description',
                  style: TextStyle(fontSize: 13, color: AppColors.textLight)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                enabled: _editing,
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),

              const SizedBox(height: 14),

              // ── Price ──────────────────────────────────────
              const Text('Price',
                  style: TextStyle(fontSize: 13, color: AppColors.textLight)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceCtrl,
                enabled: _editing,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v.trim()) == null) return 'Enter a valid price';
                  return null;
                },
                decoration: const InputDecoration(
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),

              const SizedBox(height: 28),

              // ── Save Button (edit mode only) ───────────────
              if (_editing)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save Changes',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
