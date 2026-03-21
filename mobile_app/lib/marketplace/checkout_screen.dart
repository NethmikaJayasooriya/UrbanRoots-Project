import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'cart_model.dart';
import 'marketplace_theme.dart';
import 'marketplace_api.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _paymentMethod = 'cod';
  bool _isProcessing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _processPayment(double total) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isProcessing = true);

    try {
      final orderData = {
        'name': _nameController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'totalAmount': total,
        'paymentMethod': _paymentMethod,
        'items': context.read<CartModel>().items.map((e) => e.toJson()).toList(),
      };

      final orderId = await MarketplaceApi.createOrder(orderData);

      if (_paymentMethod == 'cod') {
        if (!mounted) return;
        _showSuccessDialog();
      } else if (_paymentMethod == 'card') {
        // Setup PayHere for Card Payment
        Map paymentObject = {
          "sandbox": true,
          "merchant_id": "1234567", // Placeholder
          "merchant_secret": "xyz123", // Placeholder
          "notify_url": "${MarketplaceApi.baseUrl}/marketplace/payhere/notify",
          "order_id": orderId,
          "items": "UrbanRoots Order",
          "amount": total.toString(),
          "currency": "LKR",
          "first_name": _nameController.text.split(' ').first,
          "last_name": _nameController.text.split(' ').length > 1 ? _nameController.text.split(' ').last : '',
          "email": "user@urbanroots.com",
          "phone": _phoneController.text,
          "address": _addressController.text,
          "city": "Colombo",
          "country": "Sri Lanka",
          "delivery_address": _addressController.text,
          "delivery_city": "Colombo",
          "delivery_country": "Sri Lanka",
        };

        PayHere.startPayment(
          paymentObject,
          (paymentId) {
            if (!mounted) return;
            _showSuccessDialog();
          },
          (error) {
            if (!mounted) return;
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment Failed: $error', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
            );
          },
          () {
            if (!mounted) return;
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment Canceled', style: TextStyle(color: MarketplaceTheme.textWhite)), backgroundColor: Colors.orange),
            );
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order Error: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog() {
    setState(() => _isProcessing = false);
    context.read<CartModel>().clearCart();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: MarketplaceTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: MarketplaceTheme.primaryGreen.withOpacity(0.3))),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(shape: BoxShape.circle, color: MarketplaceTheme.primaryGreen.withOpacity(0.2)),
                child: const Icon(Icons.check_circle, color: MarketplaceTheme.primaryGreen, size: 64),
              ),
              const SizedBox(height: 24),
              const Text('Order Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite)),
              const SizedBox(height: 12),
              const Text('Thank you for shopping with UrbanRoots. Let’s grow together!', textAlign: TextAlign.center, style: TextStyle(color: MarketplaceTheme.textGray, height: 1.5)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: MarketplaceTheme.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close checkout
                    Navigator.pop(context); // Close cart
                  },
                  child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Back to Shop', style: TextStyle(color: MarketplaceTheme.darkGreen, fontWeight: FontWeight.bold, fontSize: 16))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Scaffold(
      backgroundColor: MarketplaceTheme.background,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite)),
        backgroundColor: MarketplaceTheme.cardColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: MarketplaceTheme.primaryGreen),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty', style: TextStyle(color: MarketplaceTheme.textGray, fontSize: 16)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Shipping Details'),
                  const SizedBox(height: 16),
                  _buildForm(),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Order Summary'),
                  const SizedBox(height: 16),
                  _buildOrderSummary(cart),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Payment Method'),
                  const SizedBox(height: 16),
                  _buildPaymentMethods(),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MarketplaceTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: _isProcessing ? 0 : 8,
                        shadowColor: MarketplaceTheme.primaryGreen.withOpacity(0.5),
                      ),
                      onPressed: _isProcessing ? null : () => _processPayment(cart.totalPrice),
                      child: _isProcessing
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: MarketplaceTheme.darkGreen, strokeWidth: 3))
                          : Text('Place Order (Rs. ${cart.totalPrice.toStringAsFixed(2)})', style: const TextStyle(fontSize: 18, color: MarketplaceTheme.darkGreen, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite));
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: MarketplaceTheme.glassBox(radius: 16),
        child: Column(
          children: [
            _buildTextField(controller: _nameController, label: 'Full Name', icon: Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(controller: _addressController, label: 'Delivery Address', icon: Icons.location_on_outlined, maxLines: 2),
            const SizedBox(height: 16),
            _buildTextField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: MarketplaceTheme.textWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: MarketplaceTheme.textGray),
        prefixIcon: Icon(icon, color: MarketplaceTheme.primaryGreen.withOpacity(0.7)),
        filled: true,
        fillColor: MarketplaceTheme.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: MarketplaceTheme.primaryGreen.withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: MarketplaceTheme.primaryGreen.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MarketplaceTheme.primaryGreen, width: 1.5)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildOrderSummary(CartModel cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: MarketplaceTheme.glassBox(radius: 16),
      child: Column(
        children: [
          ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.name} x${item.quantity}', style: const TextStyle(color: MarketplaceTheme.textWhite, fontSize: 14)),
                    Text('Rs. ${(item.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(color: MarketplaceTheme.textGray, fontSize: 14)),
                  ],
                ),
              )),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.white24),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite)),
              Text('Rs. ${cart.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MarketplaceTheme.primaryGreen)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      decoration: MarketplaceTheme.glassBox(radius: 16),
      child: Column(
        children: [
          Theme(
            data: ThemeData.dark().copyWith(unselectedWidgetColor: MarketplaceTheme.textGray),
            child: RadioListTile<String>(
              title: const Text('Cash on Delivery', style: TextStyle(color: MarketplaceTheme.textWhite)),
              subtitle: const Text('Pay when you receive the order', style: TextStyle(color: MarketplaceTheme.textGray, fontSize: 12)),
              value: 'cod',
              groupValue: _paymentMethod,
              activeColor: MarketplaceTheme.primaryGreen,
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Theme(
            data: ThemeData.dark().copyWith(unselectedWidgetColor: MarketplaceTheme.textGray),
            child: RadioListTile<String>(
              title: const Text('Credit/Debit Card', style: TextStyle(color: MarketplaceTheme.textWhite)),
              subtitle: const Text('Pay securely via PayHere', style: TextStyle(color: MarketplaceTheme.textGray, fontSize: 12)),
              value: 'card',
              groupValue: _paymentMethod,
              activeColor: MarketplaceTheme.primaryGreen,
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
          ),
        ],
      ),
    );
  }
}
