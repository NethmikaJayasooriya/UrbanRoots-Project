
import 'package:flutter/material.dart'; 

class ShoppingCart extends StatelessWidget {
  const ShoppingCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My cart'),
      ),
      
      body: const Center(
        child: Text('Your cart is empty'),
      ),
    );
  }
}