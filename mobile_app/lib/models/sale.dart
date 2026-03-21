// lib/models/sale.dart

class Sale {
  final String? id;
  final String? productId;
  final String? sellerId;
  final String productName;
  final String productImageUrl;
  final int quantity;
  final double unitPrice;
  final double total;
  final DateTime saleDate;

  const Sale({
    this.id,
    this.productId,
    this.sellerId,
    required this.productName,
    required this.productImageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.saleDate,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    // The backend joins product name + image into the sale response.
    // Expected shape:
    // {
    //   "id": "...",
    //   "product_id": "...",
    //   "seller_id": "...",
    //   "quantity": 3,
    //   "unit_price": "2.99",
    //   "total": "8.97",
    //   "sale_date": "2025-03-01T...",
    //   "product": { "name": "...", "image_url": "..." }   // joined
    // }
    final product = json['product'] as Map<String, dynamic>? ?? {};
    return Sale(
      id: json['id'] as String?,
      productId: json['product_id'] as String?,
      sellerId: json['seller_id'] as String?,
      productName: product['name'] as String? ?? 'Unknown Product',
      productImageUrl: product['image_url'] as String? ?? '',
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: double.parse(json['unit_price'].toString()),
      total: double.parse(json['total'].toString()),
      saleDate: DateTime.parse(json['sale_date'] as String),
    );
  }
}
