import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'cart_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalController = TextEditingController();

  // Payment Method State
  String _paymentMethod = 'Cash on Delivery';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final total = context.read<CartModel>().totalPrice;

      if (_paymentMethod == 'Cash on Delivery') {
        // Simulate a network request
        await Future.delayed(const Duration(seconds: 1));
        _completeOrder();
      } else if (_paymentMethod == 'Credit/Debit Card') {
        Map paymentObject = {
          "sandbox": true,
          "merchant_id": "1234588",
          "merchant_secret": "MTg5MzM3Mjc1ODQwNjIwMTMzODAyMTI2MzY0MjMxMTYyMzk4OTc3MA==",
          "notify_url": "http://yourdomain.com/notify", // TODO: Replace with real webhook
          "order_id": "Order_${DateTime.now().millisecondsSinceEpoch}",
          "items": "UrbanRoots Order",
          "amount": total.toStringAsFixed(2),
          "currency": "LKR",
          "first_name": _nameController.text.split(' ').first,
          "last_name": _nameController.text.split(' ').length > 1 ? _nameController.text.split(' ').sublist(1).join(' ') : "",
          "email": "customer@example.com", // Optional placeholder
          "phone": _contactController.text,
          "address": _addressController.text,
          "city": "Colombo", 
          "country": "Sri Lanka",
          "delivery_address": _addressController.text,
          "delivery_city": "Colombo",
          "delivery_country": "Sri Lanka",
          "custom_1": _postalController.text,
          "custom_2": ""
        };

        PayHere.startPayment(
          paymentObject,
          (paymentId) {
            _completeOrder();
          },
          (error) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Payment Failed: $error"),
                backgroundColor: Colors.red,
              ),
            );
          },
          () {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Payment Canceled"),
                backgroundColor: Colors.orange,
              ),
            );
          }
        );
      }
    }
  }

  void _completeOrder() {
    if (!mounted) return;

    // Clear the cart
    context.read<CartModel>().clearCart();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Pop all screens until we are back at the main Marketplace screen
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // We only read the cart once to get the total, watch is not strictly needed 
    // since we shouldn't be editing the cart from this screen.
    final total = context.read<CartModel>().totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: _isSubmitting
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Contact Details ───────────────────────────────────────
                    const Text(
                      'Shipping Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Full Name', Icons.person),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('Contact Number', Icons.phone),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter contact number' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: _inputDecoration('Shipping Address', Icons.home),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter shipping address' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _postalController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Postal Code', Icons.local_post_office),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter postal code' : null,
                    ),
                    const SizedBox(height: 32),

                    // ─── Payment Method ────────────────────────────────────────
                    const Text(
                      'Payment Method',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Cash on Delivery'),
                            value: 'Cash on Delivery',
                            groupValue: _paymentMethod,
                            activeColor: Colors.green,
                            onChanged: (value) {
                              setState(() => _paymentMethod = value!);
                            },
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            title: const Text('Credit/Debit Card'),
                            value: 'Credit/Debit Card',
                            groupValue: _paymentMethod,
                            activeColor: Colors.green,
                            onChanged: (value) {
                              setState(() => _paymentMethod = value!);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ─── Order Summary ─────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rs. ${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ─── Submit Button ─────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _placeOrder,
                        child: const Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
