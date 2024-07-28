import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/navigation_service.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;
  final currencyFormatter = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
  }

  void addToCart(Map<String, dynamic> product) async {
    final userId = _authService.user!.uid;

    // Query Firestore to check if the item is already in the cart
    final querySnapshot = await FirebaseFirestore.instance
        .collection("User Cart")
        .where('UserId', isEqualTo: userId)
        .where('name', isEqualTo: product['name'])
        .get();

    if (querySnapshot.docs.isEmpty) {
      // If the item is not in the cart, add it
      FirebaseFirestore.instance.collection("User Cart").add({
        'UserId': userId,
        'name': product['name'],
        'description': product['description'],
        'price': product['price'],
        'image': product['image'],
        'quantity': 1,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '선택하신 상품이 카트에 담겼습니다.',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.blue,
          ),
        );
      });
    } else {
      // Item is already in the cart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '이미 카트에 담긴 상품입니다.',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 39, 89, 164).withOpacity(0.8),
                Color.fromARGB(255, 224, 155, 130),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          product['name'],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Colors.white,
            onPressed: () {
              _navigationService.pushNamed("/cart");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    product['image'],
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                product['name'],
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 55, 54, 54),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '${currencyFormatter.format(double.tryParse(product['price']))}',
                style: TextStyle(
                  fontSize: 24,
                  color: Color.fromARGB(255, 39, 89, 164),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Divider(color: Colors.grey[400]),
              SizedBox(height: 20),
              Text(
                product['description'],
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    addToCart(product);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 120, 142, 202),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  child: Text(
                    '카트에 담기',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
