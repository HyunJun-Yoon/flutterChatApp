import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/consts.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_application_1/pages/messages_page.dart';
import 'package:flutter_application_1/pages/setting_page.dart';
import 'package:flutter_application_1/services/alert_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_application_1/services/navigation_service.dart';
import 'package:flutter_application_1/widgets/chat_tile.dart';
import 'package:flutter_application_1/widgets/custom_form_field.dart';
import 'package:flutter_application_1/widgets/post.dart';
import 'package:flutter_application_1/widgets/text_field.dart';
import 'package:get_it/get_it.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with SingleTickerProviderStateMixin {
  final GetIt _getIt = GetIt.instance;
  final text1Controller = TextEditingController();
  final text2Controller = TextEditingController();
  final text3Controller = TextEditingController();
  final text4Controller = TextEditingController();
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late UserProfile userProfile;
  late User? loggedInUser = null;
  bool isPostingVisible = false;
  bool isTextFieldOpen = false;
  String? contentValue = null;
  var userName;
  var userUid;
  var userPFP;
  var userProvince;
  var userCity;
  var searchProvince;
  var searchCity;
  var result;
  var grade;
  var numberOfTransaction;
  var totalTransaction;
  String buttonLabel = '거래 지역 선택';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    getUserInfo();
  }

  void postMessage() {
    if (searchProvince != null && searchCity != null) {
      if (text1Controller.text.isNotEmpty && text2Controller.text.isNotEmpty) {
        FirebaseFirestore.instance.collection("User Posts").add({
          'UserId': _authService.user!.uid,
          'UserFirstName': userName,
          'UserProvince': userProvince,
          'UserCity': userCity,
          'TransactionProvince': searchProvince,
          'TransactionCity': searchCity,
          'UserPFP': userPFP,
          'Quantity': int.parse(text1Controller.text),
          'MO': int.parse(text2Controller.text),
          'TimeStamp': Timestamp.now(),
        }).then((_) {
          // Post added successfully, show success message
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("판매글 등록이 완료 되었습니다."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      togglePostingVisibility();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }).catchError((error) {
          // Handle error if the post couldn't be added
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text("An error occurred while adding your post."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("판매하실 내용을 입력해주세요."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        return;
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("먼저 거래 지역 설정을 해주세요."),
            content: Text("상단 '거래 지역 선택' 메뉴에서 거래 지역을 선택해주세요."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }
  }

  void postBuyMessage() {
    if (searchProvince != null && searchCity != null) {
      if (text3Controller.text.isNotEmpty && text4Controller.text.isNotEmpty) {
        FirebaseFirestore.instance.collection("BuyPosts").add({
          'UserId': _authService.user!.uid,
          'UserFirstName': userName,
          'UserProvince': userProvince,
          'UserCity': userCity,
          'TransactionProvince': searchProvince,
          'TransactionCity': searchCity,
          'UserPFP': userPFP,
          'Quantity': int.parse(text3Controller.text),
          'MO': int.parse(text4Controller.text),
          'TimeStamp': Timestamp.now(),
        }).then((_) {
          // Post added successfully, show success message
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("구매글 등록이 완료 되었습니다."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      togglePostingVisibility();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }).catchError((error) {
          // Handle error if the post couldn't be added
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text("An error occurred while adding your post."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("구매하실 내용을 입력해주세요."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        return;
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("먼저 거래 지역 설정을 해주세요."),
            content: Text("상단 '거래 지역 선택' 메뉴에서 거래 지역을 선택해주세요."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }
  }

  void togglePostingVisibility() {
    setState(() {
      isPostingVisible = !isPostingVisible;
      isTextFieldOpen = !isTextFieldOpen;
    });
  }

  String calculate() {
    if (text3Controller.text.isNotEmpty && text4Controller.text.isNotEmpty) {
      int value1 = int.parse(text3Controller.text);
      int value2 = int.parse(text4Controller.text);
      int multiply = value1 * value2;
      result = multiply.toString();
    } else if (text1Controller.text.isNotEmpty &&
        text2Controller.text.isNotEmpty) {
      int value1 = int.parse(text1Controller.text);
      int value2 = int.parse(text2Controller.text);
      int multiply = value1 * value2;
      result = multiply.toString();
    } else {
      // Handle errors, such as non-numeric input
      result = ''; // Clear the result field
    }
    return result;
  }

  void _showDropdownMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: [
              '서울특별시',
              '부산광역시',
              '대구광역시',
              '인천광역시',
              '광주광역시',
              '대전광역시',
              '울산광역시',
              '세종특별자치시',
              '경기도',
              '강원도',
              '경상남도',
              '경상북도',
              '충청남도',
              '충청북도',
              '전라남도',
              '전라북도',
              '제주도',
            ].length,
            itemBuilder: (BuildContext context, int index) {
              final item = [
                '서울특별시',
                '부산광역시',
                '대구광역시',
                '인천광역시',
                '광주광역시',
                '대전광역시',
                '울산광역시',
                '세종특별자치시',
                '경기도',
                '강원도',
                '경상남도',
                '경상북도',
                '충청남도',
                '충청북도',
                '전라남도',
                '전라북도',
                '제주도',
              ][index];
              return ListTile(
                leading: Icon(Icons.location_city),
                title: Text(
                  item,
                  style: TextStyle(
                    color: userProvince == item
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context,
                      item); // Close the bottom sheet and pass the selected item
                  setState(() {
                    searchProvince = item; // Update selected province
                    searchCity =
                        null; // Reset selected city when province changes
                    buttonLabel =
                        item; // Update button label with selected province
                  });

                  // Show second dropdown menu for cities based on selected province
                  _showSecondDropdownMenu(context, item);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showSecondDropdownMenu(BuildContext context, String selectedProvince) {
    // Define city items based on the selected province
    List<String> districts = [];
    switch (selectedProvince) {
      case '서울특별시':
        districts = [
          '종로구',
          '중구',
          '용산구',
          '성동구',
          '광진구',
          '동대문구',
          '중랑구',
          '성북구',
          '강북구',
          '도봉구',
          '노원구',
          '은평구',
          '서대문구',
          '마포구',
          '양천구',
          '강서구',
          '구로구',
          '금천구',
          '영등포구',
          '동작구',
          '관악구',
          '서초구',
          '강남구',
          '송파구',
          '강동구'
        ];
        break;

      case '부산광역시':
        districts = [
          '중구',
          '서구',
          '동구',
          '영도구',
          '부산진구',
          '동래구',
          '남구',
          '북구',
          '해운대구',
          '사하구',
          '금정구',
          '강서구',
          '연제구',
          '수영구',
          '사상구',
          '기장군'
        ];
        break;
      case '대구광역시':
        districts = ['중구', '서구', '동구', '남구', '북구', '수성구', '달서구', '달성군', '군위군'];
        break;
      case '인천광역시':
        districts = [
          '중구',
          '동구',
          '미추홀구',
          '연수구',
          '남동구',
          '부평구',
          '계양구',
          '서구',
          '강화군',
          '옹진군'
        ];
        break;
      case '광주광역시':
        districts = ['북구', '동구', '서구', '남구', '광산구'];
        break;

      case '대전광역시':
        districts = ['중구', '동구', '서구', '유성구', '대덕구'];
        break;
      case '울산광역시':
        districts = ['중구', '남구', '동구', '북구', '울주군'];
        break;
      case '세종특별자치시':
        districts = ['선택할 시/구가 없습니다.'];
        break;
      case '경기도':
        districts = [
          '수원시',
          '성남시',
          '용인시',
          '안양시',
          '안산시',
          '과천시',
          '광명시',
          '광주시',
          '군포시',
          '부천시',
          '시흥시',
          '김포시',
          '안성시',
          '오산시',
          '의왕시',
          '이천시',
          '평택시',
          '하남시',
          '화성시',
          '여주시',
          '양평군',
          '고양시',
          '구리시',
          '남양주시',
          '동두천시',
          '양주시',
          '의정부시',
          '파주시',
          '포천시'
        ];
        break;
      case '강원도':
        districts = [
          '원주시',
          '춘천시',
          '강릉시',
          '동해시',
          '속초시',
          '삼척시',
          '태백시',
          '홍천군',
          '철원군',
          '횡성군',
          '평창군',
          '정선군',
          '영월군',
          '인제군',
          '고성군',
          '양양군',
          '화천군',
          '양구군'
        ];
        break;
      case '경상남도':
        districts = [
          '창원시',
          '김해시',
          '진주시',
          '양산시',
          '거제시',
          '통영시',
          '사천시',
          '밀양시',
          '함안군',
          '거창군',
          '창녕군',
          '고성군',
          '하동군',
          '합천군',
          '남해군',
          '함양군',
          '산청군',
          '의령군'
        ];
        break;
      case '경상북도':
        districts = [
          '포항시',
          '경주시',
          '김천시',
          '안동시',
          '구미시',
          '영주시',
          '영천시',
          '상주시',
          '문경시',
          '경산시',
          '의성군',
          '청송군',
          '영양군',
          '영덕군',
          '청도군',
          '고령군',
          '성주군',
          '칠곡군',
          '예천군',
          '봉화군',
          '울진군',
          '울릉군'
        ];
        break;
      case '충청남도':
        districts = [
          '천안시',
          '공주시',
          '보령시',
          '아산시',
          '서산시',
          '논산시',
          '계룡시',
          '당진시',
          '금산군',
          '부여군',
          '서천군',
          '청양군',
          '홍성군',
          '예산군',
          '태안군'
        ];
        break;
      case '충청북도':
        districts = [
          '청주시',
          '충주시',
          '제천시',
          '보은군',
          '옥천군',
          '영동군',
          '증평군',
          '진천군',
          '괴산군',
          '음성군',
          '단양군'
        ];
        break;
      case '전라남도':
        districts = [
          '목포시',
          '여수시',
          '순천시',
          '나주시',
          '광양시',
          '담양군',
          '곡성군',
          '구례군',
          '고흥군',
          '보성군',
          '화순군',
          '장흥군',
          '강진군',
          '해남군',
          '영암군',
          '무안군',
          '함평군',
          '영광군',
          '장성군',
          '완도군',
          '진도군',
          '신안군'
        ];
        break;
      case '전라북도':
        districts = [
          '전주시',
          '익산시',
          '군산시',
          '정읍시',
          '김제시',
          '남원시',
          '완주군',
          '고창군',
          '부안군',
          '임실군',
          '순창군',
          '진안군',
          '무주군',
          '장수군'
        ];
        break;
      case '제주도':
        districts = ['제주시', '서귀포시'];
        break;
      // Add cases for other provinces if needed
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: ListView.builder(
            itemCount: districts.length,
            itemBuilder: (BuildContext context, int index) {
              final city = districts[index];
              return ListTile(
                title: Text(
                  city,
                  style: TextStyle(
                    color: userCity == city
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                onTap: () {
                  // Assign the selected district to searchCity
                  setState(() {
                    searchCity = city;
                    buttonLabel = '$selectedProvince, $city';
                  });
                  Navigator.pop(context); // Close the bottom sheet
                },
              );
            },
          ),
        );
      },
    );
  }

  getUserInfo() async {
    loggedInUser = await _authService.getCurrentUser();
    DocumentReference documentRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_authService.user!.uid);
    DocumentSnapshot documentSnapshot = await documentRef.get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      userName = data['name'].toString();
      userUid = data['uid'].toString();
      userPFP = data['pfpURL'].toString();
      userProvince = data['province'].toString();
      userCity = data['city'].toString();
      grade = data['grade'];
      numberOfTransaction = data['numberOfTransaction'];
      totalTransaction = data['totalTransaction'];
    }
  }

  void refreshUserInfo() async {
    await getUserInfo();
  }

  Future<UserProfile> getClickedUser(String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      print('User data fetched successfully: $data');
      return UserProfile.fromMap(data);
    } else {
      throw Exception(
          'User data not found'); // Throw an exception if user data is not available
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 14, 80, 186).withOpacity(0.8),
                  Color.fromARGB(255, 3, 25, 59)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            "로컬 모빅 거래소",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingPage(
                      userName: userName,
                      userUid: userUid,
                      userPFP: userPFP,
                      userProvince: userProvince,
                      userCity: userCity,
                      userEmail: loggedInUser?.email,
                      onSettingsUpdated: refreshUserInfo,
                      grade: grade,
                      numberOfTransaction: numberOfTransaction,
                      totalTransaction: totalTransaction,
                    ),
                  ),
                );
              },
              color: Colors.white,
              icon: const Icon(Icons.person),
            ),
            IconButton(
              onPressed: () async {
                bool result = await _authService.logout();
                if (result) {
                  _alertService.showToast(text: "로그아웃 되었습니다.");
                  _navigationService.pushReplacementNamed("/login");
                }
              },
              color: Color.fromARGB(255, 252, 114, 15),
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  '판매',
                  style: TextStyle(fontSize: 18), // Adjust the font size here
                ),
              ),
              Tab(
                child: Text(
                  '구매',
                  style: TextStyle(fontSize: 18), // Adjust the font size here
                ),
              ),
            ],
            labelColor: Color.fromARGB(
                255, 255, 255, 255), // Color of the selected tab label
            unselectedLabelColor: Color.fromARGB(
                255, 144, 143, 143), // Color of the unselected tab labels
          ),
        ),
        body: TabBarView(
          children: [
            // Content for the "Sell" tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        _showDropdownMenu(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 194, 217, 247),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.only(
                              bottom: 1,
                              left: 12,
                              right: 12), // **Remove top padding**
                        ),
                        // Optionally, adjust the minimum size to prevent changes in button size
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size.fromHeight(
                              48), // Example height, adjust as needed
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 8),
                          Text(
                            buttonLabel,
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("User Posts")
                          .orderBy(
                            "TimeStamp",
                            descending: true,
                          )
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            color: Color.fromARGB(255, 255, 255,
                                255), // Background color for the ListView
                            child: ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final post = snapshot.data!.docs[index];
                                return Post(
                                  quantity: post['Quantity'],
                                  mo: post['MO'],
                                  postId: post.id,
                                  user: post['UserFirstName'],
                                  userUid: post['UserId'],
                                  postingTime: post['TimeStamp'],
                                  userPfp: post['UserPFP'],
                                  userProvince: post['UserProvince'],
                                  userCity: post['UserCity'],
                                  transactionProvince:
                                      post['TransactionProvince'],
                                  transactionCity: post['TransactionCity'],
                                  searchProvince: searchProvince,
                                  searchCity: searchCity,
                                  loggedInUseruid: loggedInUser!.uid,
                                  grade: grade,
                                  totalTransaction: totalTransaction,
                                  numberOfTransaction: numberOfTransaction,
                                  onTap: () async {
                                    try {
                                      UserProfile user =
                                          await getClickedUser(post['UserId']);
                                      final chatExists =
                                          await _databaseService.checkChatExits(
                                        _authService.user!.uid,
                                        user.uid!,
                                      );
                                      if (!chatExists) {
                                        await _databaseService.createNewChat(
                                          _authService.user!.uid,
                                          user.uid!,
                                        );
                                      }
                                      _navigationService.push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ChatPage(chatUser: user);
                                          },
                                        ),
                                      );
                                    } catch (e) {
                                      print('Error fetching user data: $e');
                                      // Handle the error appropriately, such as showing an error message
                                    }
                                  },
                                );
                              },
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: isPostingVisible,
                        child: GestureDetector(
                          onTap: togglePostingVisibility,
                          child: Container(
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              Icons.remove_circle_outline,
                              size: 20,
                              color: Color.fromARGB(255, 202, 89, 80),
                            ),
                          ),
                        ),
                      ),
                      if (!isPostingVisible &&
                          searchProvince != null &&
                          searchCity != null)
                        GestureDetector(
                          onTap: togglePostingVisibility,
                          child: Container(
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              Icons.add_circle_outlined,
                              size: 45,
                              color: Color.fromARGB(255, 14, 102, 174),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Visibility(
                    visible: isPostingVisible,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '판매글 작성하기',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 25.0,
                                      ),
                                    ),
                                    SizedBox(
                                        height: 10), // Add s// New input box
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: MyTextField(
                                            controller:
                                                text2Controller, // New controller for the new text field
                                            hintText:
                                                "단위 가격/MO", // Hint text for the new input box
                                            obscureText: false,
                                            defaultText: "KRW",
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            10), // Add some space between the input boxes
                                    // Original input box
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: MyTextField(
                                            controller: text1Controller,
                                            hintText: "수량",
                                            obscureText: false,
                                            defaultText: "MO",
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            10), // Add some space between the input boxes
                                    // Original input box
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 20,
                                              left:
                                                  10), // Padding for the title
                                          child: Text(
                                            '총 거래대금:',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Color.fromARGB(255, 94,
                                                      93, 93), // Border color
                                                  width: 1.0, // Border width
                                                ),
                                              ),
                                            ),
                                            padding: EdgeInsets.only(
                                                bottom:
                                                    10), // Padding only at the bottom
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  calculate(),
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        5), // Add some space between the result and currency
                                                Text(
                                                  '원/KRW', // Currency symbol
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: const Color.fromARGB(
                                                        255, 128, 127, 127),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                10), // Add some space between the text and the title
                                      ],
                                    ),

                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Submit bar button
                          Container(
                            width: double.infinity,
                            height: 50.0,
                            child: ElevatedButton(
                              onPressed: postMessage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 194, 217, 247),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              child: Text(
                                '등록하기',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            // Content for the "Buy" tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        _showDropdownMenu(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 194, 217, 247),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.only(
                              bottom: 1,
                              left: 12,
                              right: 12), // **Remove top padding**
                        ),
                        // Optionally, adjust the minimum size to prevent changes in button size
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size.fromHeight(
                              48), // Example height, adjust as needed
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 8),
                          Text(
                            buttonLabel,
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("BuyPosts")
                          .orderBy(
                            "TimeStamp",
                            descending: true,
                          )
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final post = snapshot.data!.docs[index];
                              return Post(
                                quantity: post['Quantity'],
                                mo: post['MO'],
                                postId: post.id,
                                user: post['UserFirstName'],
                                userUid: post['UserId'],
                                postingTime: post['TimeStamp'],
                                userPfp: post['UserPFP'],
                                userProvince: post['UserProvince'],
                                userCity: post['UserCity'],
                                transactionProvince:
                                    post['TransactionProvince'],
                                transactionCity: post['TransactionCity'],
                                searchProvince: searchProvince,
                                searchCity: searchCity,
                                grade: grade,
                                totalTransaction: totalTransaction,
                                numberOfTransaction: numberOfTransaction,
                                loggedInUseruid: loggedInUser!.uid,
                                onTap: () async {
                                  try {
                                    UserProfile user =
                                        await getClickedUser(post['UserId']);
                                    final chatExists =
                                        await _databaseService.checkChatExits(
                                      _authService.user!.uid,
                                      user.uid!,
                                    );
                                    if (!chatExists) {
                                      await _databaseService.createNewChat(
                                        _authService.user!.uid,
                                        user.uid!,
                                      );
                                    }
                                    _navigationService.push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ChatPage(chatUser: user);
                                        },
                                      ),
                                    );
                                  } catch (e) {
                                    print('Error fetching user data: $e');
                                    // Handle the error appropriately, such as showing an error message
                                  }
                                },
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error:${snapshot.error}'),
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: isPostingVisible,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16, bottom: 2),
                          child: GestureDetector(
                            onTap: togglePostingVisibility,
                            child: Container(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                                color: Color.fromARGB(255, 202, 89, 80),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!isPostingVisible &&
                          searchProvince != null &&
                          searchCity != null)
                        GestureDetector(
                          onTap: togglePostingVisibility,
                          child: Container(
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              Icons.add_circle_outlined,
                              size: 45,
                              color: Color.fromARGB(255, 14, 102, 174),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Visibility(
                    visible: isPostingVisible,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '구매글 작성하기',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 25.0,
                                      ),
                                    ),
                                    SizedBox(
                                        height: 10), // Add s// New input box
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: MyTextField(
                                            controller:
                                                text4Controller, // New controller for the new text field
                                            hintText:
                                                "단위 가격/MO", // Hint text for the new input box
                                            obscureText: false,
                                            defaultText: "KRW",
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            10), // Add some space between the input boxes
                                    // Original input box
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: MyTextField(
                                            controller: text3Controller,
                                            hintText: "수량",
                                            obscureText: false,
                                            defaultText: "MO",
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            10), // Add some space between the input boxes
                                    // Original input box
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 20,
                                              left:
                                                  10), // Padding for the title
                                          child: Text(
                                            '총 거래대금:',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Color.fromARGB(255, 94,
                                                      93, 93), // Border color
                                                  width: 1.0, // Border width
                                                ),
                                              ),
                                            ),
                                            padding: EdgeInsets.only(
                                                bottom:
                                                    10), // Padding only at the bottom
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  calculate(),
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        5), // Add some space between the result and currency
                                                Text(
                                                  '원/KRW', // Currency symbol
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: const Color.fromARGB(
                                                        255, 128, 127, 127),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                10), // Add some space between the text and the title
                                      ],
                                    ),

                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Submit bar button
                          Container(
                            width: double.infinity,
                            height: 50.0,
                            child: ElevatedButton(
                              onPressed: postBuyMessage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 194, 217, 247),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              child: Text(
                                '등록하기',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
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
          currentIndex: _selectedIndex ?? 0, // Add null check
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor:
              Colors.grey, // Optional: Set unselected item color
          type: BottomNavigationBarType.fixed, // Add this line
          onTap: (index) {
            setState(() {
              _selectedIndex = index; // Update the selected index
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
      ),
    );
  }
}
