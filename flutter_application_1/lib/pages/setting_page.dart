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
  final totalTransaction;
  final numberOfTransaction;
  final VoidCallback onSettingsUpdated;

  const SettingPage({
    super.key,
    required this.userName,
    required this.userUid,
    required this.userPFP,
    required this.userProvince,
    required this.userCity,
    required this.userEmail,
    required this.totalTransaction,
    required this.numberOfTransaction,
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
                      numberOfTransaction: widget.numberOfTransaction,
                      totalTransaction: widget.totalTransaction,
                      onSettingsUpdated: widget.onSettingsUpdated,
                    ),
                  ),
                );
              },
            ),
            _settingsOption(
              context: context,
              title: '현재 등급',
              icon: Icons.bar_chart,
              trailingText: '일반 등급',
              trailingTextStyle: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
              onTap: () {
                // Navigate to Current Level Page
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
            Row(
              children: [
                Icon(Icons.monetization_on,
                    color: Theme.of(context).colorScheme.primary, size: 24),
                SizedBox(width: 8),
                Text(
                  '거래 정보',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoTile('거래 수', widget.numberOfTransaction.toString(),
                    Icons.list_alt),
                _infoTile(
                    '총 금액', '₩${widget.totalTransaction}', Icons.attach_money),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 30),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
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
