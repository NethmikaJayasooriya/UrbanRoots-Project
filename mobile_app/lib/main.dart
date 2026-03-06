import 'package:flutter/material.dart';



import 'marketplace/marketplaceScreen1.dart'; 



void main() {

  runApp(const UrbanRootsApp());

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