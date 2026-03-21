import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/marketplace/marketplace_screen.dart';
import 'package:mobile_app/marketplace/cart_model.dart';
import 'app_theme.dart';
import 'package:mobile_app/models/seller.dart';
//import 'package:mobile_app/pages/seller/seller_onboarding_page.dart';
//import 'package:mobile_app/pages/seller/update_seller_details.dart';

//import 'package:mobile_app/models/products.dart';
//import 'package:mobile_app/pages/seller/add_product_page.dart';
//import 'package:mobile_app/pages/seller/view_product_page.dart';
//import 'package:mobile_app/pages/seller/seller_products_page.dart';
//import 'package:mobile_app/pages/seller/sales_page.dart';
import 'package:mobile_app/pages/seller/seller_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: const UrbanRootsApp(),
    ),
  );
}

class UrbanRootsApp extends StatelessWidget {
  const UrbanRootsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrbanRoots',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      home: const MarketplaceScreen1(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: SellerPage(
        seller: Seller(
          id: 'PLACEHOLDER',
          uid: 'PLACEHOLDER',
          rating: 0,
          isVerified: false,
        ),
      ),
    );
  }
}
