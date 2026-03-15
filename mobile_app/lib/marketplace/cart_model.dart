// cart_model.dart
import 'package:flutter/material.dart';

// Represents a single product
class CartItem {
  final String name;
  final String category;
  final double price;
  int quantity;

  CartItem({
    required this.name,
    required this.category,
    required this.price,
    this.quantity = 1,
  });
}

// Holds the list of items and notifies listeners on change
class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.price * item.quantity);

  void addItem(CartItem newItem) {
    // If item already exists, increase quantity instead of adding duplicate
    final existing = _items.where((i) => i.name == newItem.name).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _items.add(newItem);
    }
    notifyListeners(); // Tells Flutter to rebuild any widgets listening to this model
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }
}