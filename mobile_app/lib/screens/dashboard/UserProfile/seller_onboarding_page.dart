// lib/pages/seller/seller_onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_app/models/seller.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/style.dart';

/// Collects business details and regulatory documents required to register a new Seller.

class SellerOnboardingPage extends StatefulWidget {
  final String uid;                         // Supabase auth user id
  final void Function(Seller) onOnboarded;  // callback when done

  const SellerOnboardingPage({
    super.key,
    required this.uid,
    required this.onOnboarded,
  });

  @override
  State<SellerOnboardingPage> createState() => _SellerOnboardingPageState();
}

class _SellerOnboardingPageState extends State<SellerOnboardingPage> {
  final _formKey    = GlobalKey<FormState>();
  final _brandCtrl  = TextEditingController();
  final _emailCtrl  = TextEditingController();

  PlatformFile? _logoFile;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _brandCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) setState(() => _logoFile = result.files.first);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final payload = {
        'uid': widget.uid,
        'brand_name': _brandCtrl.text.trim(),
        'business_email': _emailCtrl.text.trim(),
        // TODO: upload logo to Supabase Storage and send the URL
        'logo_url': '',
      };

      final seller = await ApiService.createSeller(payload);

      // Tell SellerGate we're done — it will swap to SellerPage
      widget.onOnboarded(seller);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
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
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.eco, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'UrbanRoots',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Become a Seller',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain),
              ),
              const SizedBox(height: 6),
              const Text(
                'Fill in your business details to get started.',
                style: TextStyle(color: AppColors.textdim, fontSize: 13),
              ),
              const SizedBox(height: 32),

              // ── Business Logo ──────────────────────────
              _label('Business Logo'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(
                      color: _logoFile != null
                          ? AppColors.primary
                          : AppColors.border,
                      width: _logoFile != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: _logoFile?.bytes != null
                            ? Image.memory(_logoFile!.bytes!,
                                width: 48, height: 48, fit: BoxFit.cover)
                            : const SizedBox(
                                width: 48, height: 48,
                                child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AppColors.textdim),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _logoFile != null
                              ? '${_logoFile!.name}  '
                                '(${(_logoFile!.size / 1024).toStringAsFixed(0)} KB)'
                              : 'Tap to upload logo (PNG / JPG)',
                          style: TextStyle(
                            color: _logoFile != null
                                ? AppColors.primary
                                : AppColors.textdim,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        'Browse',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Brand Name ─────────────────────────────
              _label('Brand Name'),
              const SizedBox(height: 8),
              _textField(
                _brandCtrl,
                'e.g. GreenLeaf Co.',
                Icons.eco_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),

              const SizedBox(height: 20),

              // ── Business Email ─────────────────────────
              _label('Business Email'),
              const SizedBox(height: 8),
              _textField(
                _emailCtrl,
                'hello@yourbrand.com',
                Icons.alternate_email,
                type: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),

              // Error
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 13)),
                ),
              ],

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.black))
                      : const Text(
                          'Start Selling',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            color: AppColors.textdim,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5),
      );

  Widget _textField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      validator: validator,
      style: const TextStyle(color: AppColors.textMain, fontSize: 14),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textdim),
        prefixIcon: Icon(icon, color: AppColors.textdim, size: 18),
        filled: true,
        fillColor: AppColors.surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide:
                const BorderSide(color: Colors.redAccent, width: 1.5)),
      ),
    );
  }
}

