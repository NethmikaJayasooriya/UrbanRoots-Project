// cart_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'price': price,
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    name: json['name'],
    category: json['category'],
    price: json['price'].toDouble(),
    quantity: json['quantity'] ?? 1,
  );
}

// Holds the list of items and notifies listeners on change
class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];
  SharedPreferences? _prefs;

  CartModel() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCart();
  }

  void _loadCart() {
    if (_prefs == null) return;
    final String? cartStr = _prefs!.getString('cart_items');
    if (cartStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cartStr);
        _items.clear();
        _items.addAll(decoded.map((e) => CartItem.fromJson(e)).toList());
        notifyListeners();
      } catch (e) {
        // If JSON is malformed, clear the broken stored cart
        _prefs!.remove('cart_items');
      }
    }
  }

  void _saveCart() {
    if (_prefs == null) return;
    final String encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
    _prefs!.setString('cart_items', encoded);
  }

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
    _saveCart();
    notifyListeners(); 
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      removeItem(item);
    } else {
      item.quantity = quantity;
      _saveCart();
      notifyListeners();
    }
  }
}