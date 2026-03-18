import 'package:flutter/material.dart';
import 'app_theme.dart';
//import 'package:mobile_app/pages/seller/seller_onboarding_page.dart';
//import 'package:mobile_app/pages/seller/update_seller_details.dart';

//import 'package:mobile_app/models/products.dart';

//import 'package:mobile_app/pages/seller/add_product_page.dart';
//import 'package:mobile_app/pages/seller/view_product_page.dart';
//import 'package:mobile_app/pages/seller/seller_products_page.dart';
//import 'package:mobile_app/pages/seller/sales_page.dart';
import 'package:mobile_app/pages/seller/seller_page.dart';

void main() {
  runApp(const UrbanRootsApp());
}

class UrbanRootsApp extends StatelessWidget {
  const UrbanRootsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SellerPage(), 
    );
  }
}
