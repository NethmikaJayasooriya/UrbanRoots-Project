// shoppingCart.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'checkout_screen.dart';
import 'marketplace_theme.dart';

class Shopping_Cart extends StatelessWidget {
  const Shopping_Cart({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Scaffold(
      backgroundColor: MarketplaceTheme.background,
      appBar: AppBar(
        title: const Text('Your Cart', style: TextStyle(fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite)),
        backgroundColor: MarketplaceTheme.cardColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: MarketplaceTheme.primaryGreen),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: MarketplaceTheme.primaryGreen.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty', style: TextStyle(fontSize: 18, color: MarketplaceTheme.textGray)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MarketplaceTheme.primaryGreen.withOpacity(0.2),
                      foregroundColor: MarketplaceTheme.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: MarketplaceTheme.primaryGreen.withOpacity(0.5))),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Shopping', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: MarketplaceTheme.glassBox(radius: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: MarketplaceTheme.primaryGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.eco, color: MarketplaceTheme.primaryGreen),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(item.category, style: const TextStyle(color: MarketplaceTheme.textGray, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('Rs. ${(item.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(color: MarketplaceTheme.lightGreen, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: MarketplaceTheme.textGray),
                                onPressed: () {
                                  if (item.quantity > 1) {
                                    cart.updateQuantity(item, item.quantity - 1);
                                  } else {
                                    cart.removeItem(item);
                                  }
                                },
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontSize: 16, color: MarketplaceTheme.textWhite, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: MarketplaceTheme.primaryGreen),
                                onPressed: () => cart.updateQuantity(item, item.quantity + 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: MarketplaceTheme.cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(color: MarketplaceTheme.primaryGreen.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))
                    ]
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite)),
                            Text(
                              'Rs. ${cart.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MarketplaceTheme.primaryGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: MarketplaceTheme.primaryGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                              );
                            },
                            child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16, color: MarketplaceTheme.darkGreen, fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}