import 'products.dart';

class Sale {
  final Products product;
  final int quantity;
  final DateTime date;

  Sale({required this.product, required this.quantity, required this.date});

  double get total => product.price * quantity;
}

// ── Dummy data helper ─────────────────────────────────────────
List<Sale> getDummySales() {
  final products = Products.getProducts();
  final now = DateTime.now();
  return [
    Sale(product: products[0], quantity: 3, date: now.subtract(const Duration(days: 2))),
    Sale(product: products[1], quantity: 5, date: now.subtract(const Duration(days: 8))),
    Sale(product: products[2], quantity: 2, date: now.subtract(const Duration(days: 15))),
    Sale(product: products[0], quantity: 1, date: now.subtract(const Duration(days: 30))),
    Sale(product: products[1], quantity: 4, date: now.subtract(const Duration(days: 60))),
    Sale(product: products[2], quantity: 6, date: now.subtract(const Duration(days: 90))),
    Sale(product: products[0], quantity: 2, date: now.subtract(const Duration(days: 120))),
    Sale(product: products[1], quantity: 3, date: now.subtract(const Duration(days: 180))),
    Sale(product: products[0], quantity: 7, date: now.subtract(const Duration(days: 270))),
    Sale(product: products[2], quantity: 1, date: now.subtract(const Duration(days: 340))),
  ];
}

// ─────────────────────────────────────────────────────────────
