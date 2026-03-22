import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/seller.dart';
import 'package:mobile_app/models/products.dart';

void main() {
  group('Seller Model Tests', () {
    test('Seller.fromJson parses correctly', () {
      final json = {
        'id': '123',
        'uid': 'uid-456',
        'brand_name': 'Green Farm',
        'rating': '4.5',
        'is_verified': true,
      };

      final seller = Seller.fromJson(json);

      expect(seller.id, '123');
      expect(seller.uid, 'uid-456');
      expect(seller.brandName, 'Green Farm');
      expect(seller.rating, 4.5);
      expect(seller.isVerified, true);
    });

    test('Seller.toJson produces correct map', () {
      final seller = Seller(
        id: '123',
        uid: 'uid-456',
        rating: 3.0,
        isVerified: false,
      );

      final json = seller.toJson();

      expect(json['id'], '123');
      expect(json['uid'], 'uid-456');
      expect(json['rating'], 3.0);
      expect(json['is_verified'], false);
    });
  });

  group('Products Model Tests', () {
    test('Products.fromJson parses correctly', () {
      final json = {
        'id': 'prod-1',
        'sellerId': 'seller-1',
        'name': 'Tomato Seeds',
        'category': 'Seeds',
        'price': 150.0,
        'imageUrl': 'http://example.com/tomato.png',
        'isActive': false,
      };

      final product = Products.fromJson(json);

      expect(product.id, 'prod-1');
      expect(product.name, 'Tomato Seeds');
      expect(product.price, 150.0);
      expect(product.isActive, false);
    });

    test('Products copyWith returns new instance with updated fields', () {
      final product = Products(
        id: 'p1',
        name: 'Lettuce',
        category: 'Vegetables',
        description: 'Green',
        price: 50.0,
        imageUrl: 'url',
      );

      final updated = product.copyWith(price: 60.0, isActive: false);

      expect(updated.id, 'p1');
      expect(updated.price, 60.0);
      expect(updated.isActive, false);
      // original shouldn't change
      expect(product.price, 50.0);
    });
  });
}
