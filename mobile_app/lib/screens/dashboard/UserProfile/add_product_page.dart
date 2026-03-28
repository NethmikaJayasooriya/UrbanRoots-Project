// lib/pages/seller/add_product_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_app/models/products.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/style.dart';

class AddProductPage extends StatefulWidget {
  final String sellerId;
  const AddProductPage({
    super.key,
    required this.sellerId,
  });
  @override
  State<AddProductPage> createState() => _State();
}

class _State extends State<AddProductPage> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();

  String? _selectedCategory;
  PlatformFile? _imageFile;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) setState(() => _imageFile = result.files.first);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final bool isUuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(widget.sellerId);
      if (!isUuid) {
        throw const ApiException(400, "Critical Error: Your Seller Profile session is invalid. Please restart the app.");
      }

      String imageUrl = '';
      if (_imageFile != null) {
        imageUrl = await ApiService.uploadProductImage(_imageFile!);
      }

      final payload = {
        'seller_id': widget.sellerId,
        'name': _nameCtrl.text.trim(),
        'category': _selectedCategory,
        'description': _descCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text.trim()),
        'image_url': imageUrl,
        'is_active': true,
      };

      final created = await ApiService.createProduct(payload);

      if (!mounted) return;
      // Return the new product to the caller (SellerProductsPage)
      Navigator.pop(context, created);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        title: const Text('Add Product',
            style: TextStyle(color: AppColors.textMain)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Product Image ────────────────────────────
              _label('Product Image'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: _imageFile?.bytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(_imageFile!.bytes!,
                              fit: BoxFit.cover))
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: Colors.white38, size: 36),
                            SizedBox(height: 8),
                            Text('Tap to upload image',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 13)),
                          ],
                        ),
                ),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${_imageFile!.name}  '
                    '(${(_imageFile!.size / 1024).toStringAsFixed(0)} KB)'
                    '  · tap to change',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                  ),
                ),

              const SizedBox(height: 20),

              // ── Product Name ─────────────────────────────
              _textField(_nameCtrl, 'Product Name',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : null),

              // ── Category ─────────────────────────────────
              _label('Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: AppColors.surfaceColor,
                style: const TextStyle(
                    color: AppColors.textMain, fontSize: 14),
                decoration: _inputDeco('Select a category'),
                items: Products.categories
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedCategory = v),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Please select a category'
                    : null,
              ),
              const SizedBox(height: 14),

              // ── Description ──────────────────────────────
              _textField(_descCtrl, 'Description',
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : null),

              // ── Price ────────────────────────────────────
              _textField(
                _priceCtrl,
                'Price',
                type: const TextInputType.numberWithOptions(decimal: true),
                prefix: '\$',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d*')),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v.trim()) == null)
                    return 'Enter a valid price';
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // ── Submit ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : const Text('Add Product',
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

  // ── Helpers ──────────────────────────────────────────────

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 13, color: Colors.white70));

  InputDecoration _inputDeco(String hint, {String? prefix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
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

  Widget _textField(
    TextEditingController ctrl,
    String label, {
    TextInputType? type,
    int maxLines = 1,
    String? prefix,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            keyboardType: type,
            maxLines: maxLines,
            validator: validator,
            inputFormatters: inputFormatters,
            style: const TextStyle(
                color: AppColors.textMain, fontSize: 14),
            cursorColor: AppColors.primary,
            decoration: _inputDeco('', prefix: prefix),
          ),
        ],
      ),
    );
  }
}

