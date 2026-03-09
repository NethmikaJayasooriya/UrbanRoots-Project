import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_app/models/products.dart';


class ViewProductPage extends StatefulWidget {
  final Products product;
  const ViewProductPage({super.key, required this.product});
  @override
  State<ViewProductPage> createState() => _State();
}
