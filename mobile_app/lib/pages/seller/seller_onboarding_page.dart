import 'package:flutter/material.dart';
import 'package:mobile_app/style.dart';

class SellerOnboardingPage extends StatefulWidget {
  const SellerOnboardingPage({super.key});
  @override
  State<SellerOnboardingPage> createState() => _State();
}

class _State extends State<SellerOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _logoFile;
  String? _regFile;
  bool _loading = false;

  void _pickFile(String type) => setState(() {
        if (type == 'logo') {
          _logoFile = 'logo.png';
        } else {
          _regFile = 'registration.pdf';
        }
      });

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Application submitted! We'll review within 24h."),
        backgroundColor: Color(0xFF166534),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.eco, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('greenery',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2)),
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
              const Text('Become a Seller',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 6),
              const Text('Fill in your business details to get started.',
                  style: TextStyle(color: AppColors.textdim, fontSize: 13)),
              const SizedBox(height: 32),

              _label('Business Logo'),
              const SizedBox(height: 8),
              _uploadTile(
                icon: Icons.image_outlined,
                text: _logoFile ?? 'Upload logo (PNG / JPG)',
                picked: _logoFile != null,
                onTap: () => _pickFile('logo'),
              ),
              const SizedBox(height: 20),

              _label('Brand Name'),
              const SizedBox(height: 8),
              _textField(_brandCtrl, 'e.g. GreenLeaf Co.', Icons.eco_outlined,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 20),

              _label('Business Email'),
              const SizedBox(height: 8),
              _textField(
                  _emailCtrl, 'hello@yourbrand.com', Icons.alternate_email,
                  type: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  }),
              const SizedBox(height: 20),

              _label('Business Registration Documents'),
              const SizedBox(height: 8),
              _uploadTile(
                icon: Icons.folder_outlined,
                text: _regFile ?? 'Upload certificate or license (PDF / JPG)',
                picked: _regFile != null,
                onTap: () => _pickFile('reg'),
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.background))
                      : const Text('Start Selling',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: AppColors.textdim,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5));

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
      style: const TextStyle(color: Colors.white, fontSize: 14),
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
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Colors.redAccent, width: 1.5)),
      ),
    );
  }

  Widget _uploadTile({
    required IconData icon,
    required String text,
    required bool picked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: picked ? AppColors.primary : AppColors.border,
              width: picked ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(
                picked ? Icons.check_circle_outline : icon,
                color: picked ? AppColors.primary : AppColors.textdim,
                size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Text(text,
                    style: TextStyle(
                        color: picked ? AppColors.primary : AppColors.textdim,
                        fontSize: 13))),
            const Text('Browse',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
