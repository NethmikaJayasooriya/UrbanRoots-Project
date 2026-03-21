// lib/pages/seller/update_seller_details.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_app/models/beneficiary.dart';
import 'package:mobile_app/models/seller.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/style.dart';

class UpdateSellerDetailsPage extends StatefulWidget {
  final Seller seller;
  const UpdateSellerDetailsPage({super.key, required this.seller});

  @override
  State<UpdateSellerDetailsPage> createState() =>
      _UpdateSellerDetailsPageState();
}

class _UpdateSellerDetailsPageState
    extends State<UpdateSellerDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  late final _brandCtrl   = TextEditingController(text: widget.seller.brandName ?? '');
  late final _emailCtrl   = TextEditingController(text: widget.seller.businessEmail ?? '');
  late final _phoneCtrl   = TextEditingController(text: widget.seller.phone ?? '');
  late final _addressCtrl = TextEditingController(text: widget.seller.businessAddress ?? '');
  late final _accNameCtrl = TextEditingController(text: widget.seller.accountName ?? '');
  late final _accNoCtrl   = TextEditingController(text: widget.seller.accountNumber ?? '');
  late final _bankCtrl    = TextEditingController(text: widget.seller.bank ?? '');
  late final _branchCtrl  = TextEditingController(text: widget.seller.branch ?? '');

  PlatformFile? _logoFile;
  bool _loading = false;

  // Beneficiaries — loaded from API on init
  List<Beneficiary> _beneficiaries = [];
  bool _loadingBeneficiaries = true;

  @override
  void initState() {
    super.initState();
    _loadBeneficiaries();
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _accNameCtrl.dispose();
    _accNoCtrl.dispose();
    _bankCtrl.dispose();
    _branchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBeneficiaries() async {
    try {
      final data = await ApiService.instance
          .getBeneficiaries(widget.seller.id);
      if (mounted) {
        setState(() {
          _beneficiaries = data
              .map((b) => Beneficiary(
                    id: b['id'] as String?,
                    name: b['full_name'] as String? ?? '',
                    account: b['account_number'] as String? ?? '',
                    bank: b['bank'] as String? ?? '',
                  ))
              .toList();
          _loadingBeneficiaries = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingBeneficiaries = false);
    }
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) setState(() => _logoFile = result.files.first);
  }

  void _addBeneficiary() {
    setState(() => _beneficiaries.add(Beneficiary()));
  }

  Future<void> _removeBeneficiary(int index) async {
    final b = _beneficiaries[index];
    // If it has an id it exists in the DB — delete it
    if (b.id != null) {
      try {
        await ApiService.instance.deleteBeneficiary(b.id!);
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message),
                backgroundColor: Colors.redAccent));
        return;
      }
    }
    setState(() => _beneficiaries.removeAt(index));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // ── Update seller profile ──────────────────────────
      final payload = {
        'brand_name':       _brandCtrl.text.trim(),
        'business_email':   _emailCtrl.text.trim(),
        'phone':            _phoneCtrl.text.trim(),
        'business_address': _addressCtrl.text.trim(),
        'account_name':     _accNameCtrl.text.trim(),
        'account_number':   _accNoCtrl.text.trim(),
        'bank':             _bankCtrl.text.trim(),
        'branch':           _branchCtrl.text.trim(),
        // TODO: upload logo and send URL
        if (_logoFile != null) 'logo_url': '',
      };

      final updatedSeller = await ApiService.instance
          .updateSeller(widget.seller.id, payload);

      // ── Save new (unsaved) beneficiaries ───────────────
      for (final b in _beneficiaries) {
        if (b.id == null &&
            b.nameCtrl.text.isNotEmpty &&
            b.accountCtrl.text.isNotEmpty &&
            b.bankCtrl.text.isNotEmpty) {
          await ApiService.instance.createBeneficiary({
            'seller_id':      widget.seller.id,
            'full_name':      b.nameCtrl.text.trim(),
            'account_number': b.accountCtrl.text.trim(),
            'bank':           b.bankCtrl.text.trim(),
          });
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details updated successfully.')),
      );

      // Return updated seller to SellerPage
      Navigator.pop(context, updatedSeller);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Seller Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Business Logo ──────────────────────────
              _section('Business Logo'),
              GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: _logoFile?.bytes != null
                            ? Image.memory(_logoFile!.bytes!,
                                width: 44, height: 44, fit: BoxFit.cover)
                            : (widget.seller.logoUrl?.startsWith('http') ==
                                    true
                                ? Image.network(widget.seller.logoUrl!,
                                    width: 44, height: 44, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _logoIcon())
                                : _logoIcon()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _logoFile != null
                              ? '${_logoFile!.name}  '
                                '(${(_logoFile!.size / 1024).toStringAsFixed(0)} KB)'
                              : 'Tap to change logo',
                          style: const TextStyle(
                              color: AppColors.textdim, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textFaint),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Business Info ──────────────────────────
              _section('Business Info'),
              _field(_brandCtrl,   'Brand Name',       required: true),
              _field(_emailCtrl,   'Business Email',   type: TextInputType.emailAddress, required: true),
              _field(_phoneCtrl,   'Phone Number',     type: TextInputType.phone),
              _field(_addressCtrl, 'Business Address', maxLines: 2),

              const SizedBox(height: 20),

              // ── Payment Details ────────────────────────
              _section('Payment Details'),
              _field(_accNameCtrl, 'Account Name',   required: true),
              _field(_accNoCtrl,   'Account Number', type: TextInputType.number, required: true),
              _field(_bankCtrl,    'Bank',           required: true),
              _field(_branchCtrl,  'Branch'),

              const SizedBox(height: 20),

              // ── Beneficiaries ──────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _section('Beneficiaries', spacing: false),
                  TextButton.icon(
                    onPressed: _addBeneficiary,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_loadingBeneficiaries)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  ),
                )
              else
                ..._beneficiaries.asMap().entries.map((e) {
                  final i = e.key;
                  final b = e.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              b.id != null
                                  ? 'Beneficiary ${i + 1}'
                                  : 'New Beneficiary ${i + 1}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textdim),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.error, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _removeBeneficiary(i),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _field(b.nameCtrl, 'Full Name', required: true),
                        _field(b.accountCtrl, 'Account Number',
                            type: TextInputType.number, required: true),
                        _field(b.bankCtrl, 'Bank', required: true),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 28),

              // ── Save Button ────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
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

  Widget _logoIcon() => const SizedBox(
        width: 44, height: 44,
        child: Icon(Icons.add_photo_alternate_outlined,
            color: AppColors.textdim),
      );

  Widget _section(String title, {bool spacing = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (spacing) const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight)),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType? type,
    int maxLines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
