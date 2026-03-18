import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_app/models/beneficiary.dart';
import 'package:mobile_app/style.dart';




class UpdateSellerDetailsPage extends StatefulWidget {
  const UpdateSellerDetailsPage({super.key});
  @override
  State<UpdateSellerDetailsPage> createState() => _State();
}

class _State extends State<UpdateSellerDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final _brandCtrl   = TextEditingController(text: 'GreenLeaf Co.');
  final _emailCtrl   = TextEditingController(text: 'hello@greenleaf.com');
  final _phoneCtrl   = TextEditingController(text: '+94 77 123 4567');
  final _addressCtrl = TextEditingController(text: '12 Palm Grove, Negombo');
  final _accNameCtrl = TextEditingController(text: 'GreenLeaf Co. Ltd');
  final _accNoCtrl   = TextEditingController(text: '1234567890');
  final _bankCtrl    = TextEditingController(text: 'Commercial Bank');
  final _branchCtrl  = TextEditingController(text: 'Negombo');

  PlatformFile? _logoFile;
  bool _loading = false;

  final List<Beneficiary> _beneficiaries = [
    Beneficiary(name: 'John Silva', account: '9876543210', bank: 'BOC'),
  ];

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

  void _removeBeneficiary(int index) {
    setState(() => _beneficiaries.removeAt(index));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Details updated successfully.')),
    );
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

              // ── Business Logo ──────────────────────────────
              _section('Business Logo'),
              GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
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
                            : const SizedBox(
                                width: 44, height: 44,
                                child: Icon(Icons.add_photo_alternate_outlined,
                                    color: AppColors.textdim),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _logoFile != null
                              ? '${_logoFile!.name}  (${(_logoFile!.size / 1024).toStringAsFixed(0)} KB)'
                              : 'Tap to change logo',
                          style: const TextStyle(color: AppColors.textdim, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textFaint),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Business Info ──────────────────────────────
              _section('Business Info'),
              _field(_brandCtrl,   'Brand Name',        required: true),
              _field(_emailCtrl,   'Business Email',    type: TextInputType.emailAddress, required: true),
              _field(_phoneCtrl,   'Phone Number',      type: TextInputType.phone),
              _field(_addressCtrl, 'Business Address',  maxLines: 2),

              const SizedBox(height: 20),

              // ── Payment Details ────────────────────────────
              _section('Payment Details'),
              _field(_accNameCtrl, 'Account Name',   required: true),
              _field(_accNoCtrl,   'Account Number', type: TextInputType.number, required: true),
              _field(_bankCtrl,    'Bank',           required: true),
              _field(_branchCtrl,  'Branch'),

              const SizedBox(height: 20),

              // ── Beneficiaries ──────────────────────────────
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

              ..._beneficiaries.asMap().entries.map((e) {
                final i = e.key;
                final b = e.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Beneficiary ${i + 1}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textdim)),
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
                      _field(b.nameCtrl,    'Full Name',      required: true),
                      _field(b.accountCtrl, 'Account Number', type: TextInputType.number, required: true),
                      _field(b.bankCtrl,    'Bank',           required: true),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 28),

              // ── Save Button ────────────────────────────────
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
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

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
