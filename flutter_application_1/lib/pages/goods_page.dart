import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/productDetail_page.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/navigation_service.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/pages/registeritem_page.dart';

class GoodsPage extends StatefulWidget {
  const GoodsPage({super.key});

  @override
  State<GoodsPage> createState() => _GoodsPageState();
}

class _GoodsPageState extends State<GoodsPage> {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;
  int _selectedIndex = 1;
  final currencyFormatter = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

  // Define a list of products
  final List<Map<String, dynamic>> products = [
    {
      'name': '비트모빅 종이지갑',
      'description':
          'This is a short product description to give more details about the item.',
      'price': '5000',
      'image': 'assets/images/paper.jpg',
    },
    {
      'name': '비트모빅 티셔츠',
      'description': 'A stylish backpack suitable for all occasions.',
      'price': '32000',
      'image': 'assets/images/shirt.jpg',
    },
    // Add more products as needed
  ];

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
              style: TextStyle(color: Colors.white), // Text color
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.blue, // Set your desired color here
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
          backgroundColor: Colors.red, // Use a different color for error
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          '굿즈샵',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: products.length, // Use the length of the products list
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              color: Color(0xFFF5F5F5),
              child: InkWell(
                onTap: () {
                  // Navigate to product details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        product: product, // Pass the product data here
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          product['image'], // Use the product's image
                          width: 100,
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'], // Use the product's name
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 55, 54, 54),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              product[
                                  'description'], // Use the product's description
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${currencyFormatter.format(double.tryParse(product['price']))}', // Use the product's price
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 55, 54, 54),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    addToCart(product);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 120, 142, 202),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                  child: Text(
                                    '카트에 담기',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterItemPage()),
          );
        },
        backgroundColor: Color.fromARGB(
            255, 85, 121, 193), // Use the color similar to the one in the image
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              15), // Optional: Adjust the corner radius if needed
        ),
        child: Icon(
          Icons.edit, // The icon matches the pencil/edit icon in the image
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            label: '거래소',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: '굿즈샵',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: '메세지',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            _navigationService.pushReplacementNamed("/transaction");
          } else if (index == 1) {
            _navigationService.pushReplacementNamed("/store");
          } else if (index == 2) {
            _navigationService.pushReplacementNamed("/messages");
          }
        },
      ),
    );
  }
}
