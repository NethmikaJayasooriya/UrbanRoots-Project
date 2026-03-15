import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/marketplace/marketplaceScreen1.dart';
import 'package:mobile_app/marketplace/cart_model.dart';

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
    );
  }
}