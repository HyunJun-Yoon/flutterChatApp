import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/account_page.dart';
import 'package:flutter_application_1/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

class SettingPage extends StatefulWidget {
  final userName;
  final userUid;
  final userPFP;
  final userProvince;
  final userCity;
  final userEmail;
  final grade;
  final totalTransaction;
  final numberOfTransaction;
  final chatId;
  final VoidCallback onSettingsUpdated;

  const SettingPage({
    super.key,
    required this.userName,
    required this.userUid,
    required this.userPFP,
    required this.userProvince,
    required this.userCity,
    required this.userEmail,
    required this.grade,
    required this.totalTransaction,
    required this.numberOfTransaction,
    required this.chatId,
    required this.onSettingsUpdated,
  });

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final GetIt _getIt = GetIt.instance;
  bool notificationsEnabled = true;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('설정', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.blueGrey[50],
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _transactionSummary(), // Add the transaction summary widget
            _settingsOption(
              context: context,
              title: '계정 설정',
              icon: Icons.account_circle_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountSettingPage(
                      userName: widget.userName,
                      userUid: widget.userUid,
                      userPFP: widget.userPFP,
                      userProvince: widget.userProvince,
                      userCity: widget.userCity,
                      userEmail: widget.userEmail,
                      grade: widget.grade,
                      numberOfTransaction: widget.numberOfTransaction,
                      totalTransaction: widget.totalTransaction,
                      chatId: widget.chatId,
                      onSettingsUpdated: widget.onSettingsUpdated,
                    ),
                  ),
                );
              },
            ),
            _notificationSetting(),

            _settingsOption(
              context: context,
              title: '고객센터',
              icon: Icons.support_agent,
              onTap: () {
                // Navigate to Customer Service Page
              },
            ),
            _settingsOption(
              context: context,
              title: '서비스 이용약관',
              icon: Icons.description_outlined,
              onTap: () {
                // Navigate to Terms and Conditions Page
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionSummary() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First row with "회원 거래 정보"
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
                SizedBox(width: 8),
                Text(
                  '회원 거래 정보',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey[300], thickness: 1.5),
            SizedBox(height: 16),
            // Second row with all transaction details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoTile(
                  label: '현재 등급',
                  value: widget.grade.toString(),
                  icon: Icons.star,
                  grade: widget.grade,
                ),
                _infoTile(
                  label: '누적 거래 횟수',
                  value: widget.numberOfTransaction.toString(),
                  icon: Icons.list_alt,
                ),
                _infoTile(
                  label: '누적 거래 금액',
                  value: '₩${widget.totalTransaction}',
                  icon: Icons.attach_money,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required String label,
    required String value,
    required IconData icon,
    int grade = 0,
  }) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 8),
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 30),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          // Display value only if the label is not "현재 등급"
          if (label != '현재 등급')
            Text(
              value,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          // Add stars below the "현재 등급" text
          if (label == '현재 등급')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3, // Always generate 3 stars
                (index) => Icon(
                  Icons.star,
                  color: index < grade ? Colors.amber : Colors.grey,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _settingsOption({
    required BuildContext context,
    required String title,
    IconData? icon,
    Widget? leading,
    String? trailingText,
    TextStyle? trailingTextStyle,
    required Function() onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        leading:
            leading ?? Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        trailing: trailingText != null
            ? Text(
                trailingText,
                style: trailingTextStyle ??
                    TextStyle(
                      color: Colors.blueGrey[700],
                      fontSize: 14.0,
                    ),
              )
            : Icon(Icons.arrow_forward_ios, color: Colors.blueGrey[700]),
        onTap: onTap,
      ),
    );
  }

  Widget _notificationSetting() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        title: const Text(
          '알림 설정',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        secondary: Icon(Icons.notifications_outlined,
            color: Theme.of(context).colorScheme.primary),
        value: notificationsEnabled,
        onChanged: (value) {
          setState(() {
            notificationsEnabled = value;
          });
          // Handle notification settings change
        },
      ),
    );
  }
}
