import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Post extends StatelessWidget {
  final int quantity;
  final int mo;
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
                        IconButton(
                          onPressed: () {
                            // Implement edit functionality here
                            print('Edit button pressed');
                          },
                          icon: Icon(Icons.edit),
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
}
