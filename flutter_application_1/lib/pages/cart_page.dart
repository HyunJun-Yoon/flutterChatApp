import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/checkout_page.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/navigation_service.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;
  final currencyFormatter = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

  final List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    getUserCartInfo(); // Fetch cart items when initializing
  }

  Future<void> getUserCartInfo() async {
    final userId = _authService.user!.uid;

    // Query the user's cart items from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('User Cart')
        .where('UserId', isEqualTo: userId)
        .get();

    // Clear the existing cart items
    _cartItems.clear();

    // Populate _cartItems with data from Firestore
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      _cartItems.add(CartItem(
        id: doc.id,
        name: data['name'].toString(),
        price: double.tryParse(data['price'].toString()) ?? 0.0,
        quantity: data['quantity'] != null
            ? int.parse(data['quantity'].toString())
            : 1,
        imageUrl: data['image'].toString(),
      ));
    }

    // Refresh the UI
    setState(() {});
  }

  double get _totalPrice {
    return _cartItems.fold(
        0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _increaseQuantity(CartItem item) {
    setState(() {
      item.quantity++;
    });
  }

  void _decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      setState(() {
        item.quantity--;
      });
    }
  }

  void _removeItem(CartItem item) async {
    final userId = _authService.user!.uid;

    // Query Firestore to find the item in the cart
    final querySnapshot = await FirebaseFirestore.instance
        .collection("User Cart")
        .where('UserId', isEqualTo: userId)
        .where('name', isEqualTo: item.name)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If the item is found, remove it
      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection("User Cart")
            .doc(doc.id)
            .delete();
      }

      // Remove the item from the local list and update the UI
      setState(() {
        _cartItems.remove(item);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '상품이 카트에서 삭제되었습니다.',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green, // Use a color for successful removal
        ),
      );
    } else {
      // If the item is not found in the cart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '카트에 상품이 없습니다.',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.orange, // Use a different color for warning
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
          '카트',
          style: TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
        centerTitle: true,
      ),
      body: _cartItems.isEmpty
          ? Center(
              child: Text(
                '카트가 비어있습니다.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 8.0,
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                item.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color.fromARGB(255, 55, 54, 54),
                              ),
                            ),
                            subtitle: Text(
                              '${currencyFormatter.format(item.price)}',
                              style: TextStyle(
                                color: Color.fromARGB(255, 55, 54, 54),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 170, // Adjusted width for trailing content
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () => _decreaseQuantity(item),
                                    color: Theme.of(context)
                                        .primaryColor, // Dark Green
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () => _increaseQuantity(item),
                                    color: Theme.of(context)
                                        .primaryColor, // Dark Green
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () => _removeItem(item),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(height: 1), // Adjusted the height to fit the layout
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '합계 금액:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${currencyFormatter.format(_totalPrice)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 55, 54, 54),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16), // Adjusted spacing for the button
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(),
                          ),
                        );
                        // Implement checkout functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color.fromARGB(255, 118, 168, 243), // Dark Green

                        textStyle: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      child: Text(
                        '구매하기',
                        style: TextStyle(
                          fontSize: 15,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight:
                              FontWeight.bold, // Change to red text color
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}

// CartItem class to represent individual cart items
class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });
}
