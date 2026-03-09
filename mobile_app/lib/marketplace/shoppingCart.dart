// 1. THIS IS THE MISSING MAGIC LINE! It tells Dart what widgets are.
import 'package:flutter/material.dart'; 

class ShoppingCart extends StatelessWidget {
  const ShoppingCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My cart'),
      ),
      // 2. Changed 'Body:' to 'body:' (Dart requires lowercase for properties)
      body: const Center(
        child: Text('Your cart is empty'),
      ),
    );
  }
}