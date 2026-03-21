// lib/models/products.dart

class Products {
  final String? id;
  final String? sellerId;
  String name;
  String category;
  String description;
  double price;
  String imageUrl;
  bool isActive;

  Products({
    this.id,
    this.sellerId,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isActive = true,
  });

  // ── Category list ──────────────────────────────────────────
  static const List<String> categories = [
    'Vegetables',
    'Fruits',
    'Herbs',
    'Microgreens',
    'Seedlings',
    'Fertilizers',
    'Equipment',
    'Other',
  ];

  // ── Serialisation ──────────────────────────────────────────
  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['id'] as String?,
      sellerId: (json['sellerId'] ?? json['seller_id']) as String?,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String? ?? '',
      price: double.parse(json['price'].toString()),
      imageUrl: (json['imageUrl'] ?? json['image_url']) as String? ?? '',
      isActive: (json['isActive'] ?? json['is_active']) as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (sellerId != null) 'seller_id': sellerId,
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'is_active': isActive,
      };

  Products copyWith({
    String? id,
    String? sellerId,
    String? name,
    String? category,
    String? description,
    double? price,
    String? imageUrl,
    bool? isActive,
  }) =>
      Products(
        id: id ?? this.id,
        sellerId: sellerId ?? this.sellerId,
        name: name ?? this.name,
        category: category ?? this.category,
        description: description ?? this.description,
        price: price ?? this.price,
        imageUrl: imageUrl ?? this.imageUrl,
        isActive: isActive ?? this.isActive,
      );
}
