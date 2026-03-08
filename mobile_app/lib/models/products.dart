class Products {
  String name;
  String description;
  double price;
  String imageUrl;

  Products({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  static List<Products> getProducts() {
    List<Products> products = [];

    products.add(Products(
      name: 'Fresh Tomatoes',
      description: 'Juicy and ripe tomatoes, perfect for salads and cooking.',
      price: 2.99,
      imageUrl: 'assets/images/tomatoes.jpg',
    ));
    products.add(Products(
      name: 'Organic Carrots',
      description: 'Crunchy and sweet organic carrots, great for snacking.',
      price: 1.99,
      imageUrl: 'assets/images/carrots.jpg',
    ));
    products.add(Products(
      name: 'Green Lettuce',
      description: 'Crisp and fresh green lettuce, ideal for sandwiches and salads.',
      price: 1.49,
      imageUrl: 'assets/images/lettuce.jpg',
    ));

    return products;
  }

}