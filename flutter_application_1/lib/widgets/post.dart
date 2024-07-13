import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Post extends StatelessWidget {
  final int quantity;
  final int mo;
  final String postId;
  final String user;
  final String? userUid;
  final String? userPfp;
  final String? userProvince;
  final String? userCity;
  final String? transactionProvince;
  final String? transactionCity;
  final String? searchProvince;
  final String? searchCity;
  final String? loggedInUseruid;
  final Function()? onTap;
  final Timestamp postingTime;

  const Post({
    Key? key,
    required this.quantity,
    required this.mo,
    required this.postId,
    required this.user,
    required this.userUid,
    required this.userPfp,
    required this.userProvince,
    required this.userCity,
    required this.transactionProvince,
    required this.transactionCity,
    required this.searchProvince,
    required this.searchCity,
    required this.postingTime,
    required this.loggedInUseruid,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool showPost =
        (searchProvince != null && transactionProvince == searchProvince) &&
            (searchCity != null && transactionCity == searchCity);

    final currencyFormatter =
        NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    final oneDecimalFormatter = NumberFormat('#,##0.0#', 'ko_KR');

    String formatPostingTime(Timestamp time) {
      Duration difference = DateTime.now().difference(time.toDate());
      if (difference.inMinutes < 1) {
        return '방금';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}분 전';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}시간 전';
      } else {
        return DateFormat('yyyy-MM-dd').format(time.toDate());
      }
    }

    int totalPrice = quantity * mo;

    Color backgroundColor = loggedInUseruid != null &&
            userUid == loggedInUseruid
        ? Color.fromARGB(255, 245, 206, 208) // Light pink for logged-in user
        : Color.fromARGB(255, 255, 255, 255); // Light blue for others

    return showPost
        ? GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: userPfp != null
                            ? NetworkImage(userPfp!)
                            : AssetImage('assets/default_avatar.png')
                                as ImageProvider,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              formatPostingTime(postingTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (loggedInUseruid != null && userUid == loggedInUseruid)
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                _showEditDialog(context);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                _confirmDelete(context);
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(color: Colors.black12),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KRW',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            currencyFormatter.format(mo),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '수량',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${oneDecimalFormatter.format(quantity)} MO',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Divider(color: Colors.black12),
                  SizedBox(height: 6),
                  Text(
                    '총 거래대금 ${currencyFormatter.format(totalPrice)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          )
        : SizedBox();
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController quantityController =
        TextEditingController(text: quantity.toString());
    TextEditingController moController =
        TextEditingController(text: mo.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: '수량'),
                ),
                TextField(
                  controller: moController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'MO'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    int updatedQuantity = int.parse(quantityController.text);
                    int updatedMo = int.parse(moController.text);

                    FirebaseFirestore.instance
                        .collection('User Posts')
                        .doc(postId)
                        .update({
                      'Quantity': updatedQuantity,
                      'MO': updatedMo,
                    }).then((_) {
                      Navigator.pop(context);
                      _showDialog(context, "게시글이 업데이트 되었습니다.");
                    }).catchError((error) {
                      print("업데이트에 실패하였습니다.: $error");
                    });
                  },
                  child: Text('업데이트'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("삭제 확인"),
          content: Text("정말로 이 게시글을 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('User Posts')
                    .doc(postId)
                    .delete()
                    .then((_) {
                  Navigator.of(context).pop();
                  _showDialog(context, "게시글이 삭제 되었습니다.");
                }).catchError((error) {
                  print("삭제에 실패하였습니다.: $error");
                });
              },
              child: Text("삭제"),
            ),
          ],
        );
      },
    );
  }

  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
