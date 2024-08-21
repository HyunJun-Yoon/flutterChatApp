import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_application_1/services/alert_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_application_1/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
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
                Color.fromARGB(255, 87, 109, 101).withOpacity(0.8),
                Color.fromARGB(255, 20, 81, 63),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          '메세지',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildUI(),
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
          switch (index) {
            case 0:
              _navigationService.pushReplacementNamed("/transaction");
              break;
            case 1:
              _navigationService.pushReplacementNamed("/store");
              break;
            case 2:
              _navigationService.pushReplacementNamed("/messages");
              break;
          }
        },
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: _chatList(),
      ),
    );
  }

  Widget _chatList() {
    return StreamBuilder<List<UserProfile>?>(
      stream: _databaseService.getChatUserProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "데이터를 가져오는데 실패하였습니다.",
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "메세지가 없습니다.",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
          );
        }

        final List<UserProfile> users = snapshot.data!;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            UserProfile user = users[index];

            return ListTile(
              contentPadding: const EdgeInsets.all(15.0),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: user.pfpURL != null
                    ? NetworkImage(user.pfpURL!)
                    : AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
              ),
              title: Text(
                user.name ?? 'Unknown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check_box_rounded),
                    color: Color.fromARGB(255, 91, 145, 238),
                    onPressed: () async {
                      int _selectedRating = 3; // Default rating is 1
                      double _transactionAmount = 0.0;
                      final _formKey = GlobalKey<FormState>();

                      bool? confirmTransaction = await showDialog(
                        context: context,
                        builder: (context) => StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: Text('거래 완료 확인'),
                              content: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${user.name} 회원님과의 거래를 완료하시겠습니까?',
                                      style: TextStyle(fontSize: 17.0),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      '거래 평점을 남겨주세요:',
                                      style: TextStyle(fontSize: 17.0),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        return IconButton(
                                          icon: Icon(
                                            index < _selectedRating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _selectedRating = index + 1;
                                            });
                                          },
                                        );
                                      }),
                                    ),
                                    SizedBox(height: 20),
                                    TextFormField(
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      decoration: InputDecoration(
                                        labelText: '거래 금액',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        final doubleAmount =
                                            double.tryParse(value ?? '');
                                        if (value == null || value.isEmpty) {
                                          return '거래 금액을 입력해 주세요.';
                                        } else if (doubleAmount == null) {
                                          return '올바른 숫자를 입력해 주세요.';
                                        } else if (doubleAmount <= 100000) {
                                          return '거래 금액은 100,000 보다 커야 합니다.';
                                        } else if (doubleAmount > 10000000) {
                                          return '거래 금액은 10,000,000 이하이어야 합니다.';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        setState(() {
                                          _transactionAmount =
                                              double.tryParse(value) ?? 0.0;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      if (_selectedRating == 0) {
                                        _alertService.showToast(
                                          text: '거래 평점은 0일 수 없습니다.',
                                          icon: Icons.warning,
                                        );
                                        return;
                                      }

                                      bool? finalConfirmation =
                                          await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('최종 확인'),
                                          content: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: '거래를 완료하시겠습니까?\n',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16.0),
                                                ),
                                                TextSpan(
                                                  text: '거래 완료 시 메세지가 삭제됩니다.',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                              child: Text('취소'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                              child: Text('확인'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (finalConfirmation == true) {
                                        Navigator.of(context).pop(true);
                                      }
                                    }
                                  },
                                  child: Text('완료'),
                                ),
                              ],
                            );
                          },
                        ),
                      );

                      if (confirmTransaction == true) {
                        // Handle the transaction completion logic here, including the rating
                        _alertService.showToast(
                          text: '${user.name} 회원님과의 거래를 완료하셨습니다.',
                          icon: Icons.check_circle,
                        );

                        // Optionally, you can store the rating and transaction amount in the database or perform any other action
                        await _databaseService.storeRating(
                          loggedInUserId: _authService.user!.uid,
                          otherUserId: user.uid!,
                          rating: _selectedRating,
                          currentTransactionAmount:
                              _transactionAmount, // Add this line to store the transaction amount
                        );

                        await _databaseService.deleteChat(
                            _authService.user!.uid, user.uid!);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () async {
                      bool? confirmDelete = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('메세지 삭제'),
                          content: Text('${user.name} 회원님과의 메세지를 삭제하시겠습니까?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text('취소'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await _databaseService.deleteChat(
                                  _authService.user!.uid,
                                  user.uid!,
                                );
                                Navigator.of(context).pop(true);
                              },
                              child: Text('삭제'),
                            ),
                          ],
                        ),
                      );

                      if (confirmDelete == true) {
                        setState(() {
                          users.removeAt(index);
                        });

                        _alertService.showToast(
                          text: '${user.name} 회원님과의 메세지가 삭제되었습니다.',
                          icon: Icons.delete,
                        );
                      }
                    },
                  ),
                ],
              ),
              onTap: () async {
                final chatExists = await _databaseService.checkChatExits(
                  _authService.user!.uid,
                  user.uid!,
                );
                if (!chatExists) {
                  _alertService.showToast(
                    text: '${user.name} 회원님과의 메세지가 삭제되었거나 존재하지 않습니다.',
                    icon: Icons.delete,
                  );
                }
                _navigationService.push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ChatPage(chatUser: user);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
