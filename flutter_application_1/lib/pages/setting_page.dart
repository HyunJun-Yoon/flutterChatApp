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
  final VoidCallback onSettingsUpdated;

  const SettingPage({
    super.key,
    required this.userName,
    required this.userUid,
    required this.userPFP,
    required this.userProvince,
    required this.userCity,
    required this.userEmail,
    required this.onSettingsUpdated,
  });

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // Variable to manage notification settings
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
                      onSettingsUpdated: widget.onSettingsUpdated,
                    ),
                  ),
                );
              },
            ),
            _settingsOption(
              context: context,
              title: '현재 등급',
              icon: Icons.bar_chart, // Remove the icon
              trailingText: '일반 등급', // Add your own text here
              trailingTextStyle: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0), // Custom color
                fontSize: 16.0, // Custom font size
                fontWeight: FontWeight.w400, // Custom font weight
              ),
              onTap: () {
                // Navigate to Current Level Page
              },
            ),
            _notificationSetting(), // Notification setting with switch
            _settingsOption(
              context: context,
              title: '사용자 가이드',
              icon: Icons.help_outline,
              onTap: () {
                // Navigate to User Guide Page
              },
            ),
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

  Widget _settingsOption({
    required BuildContext context,
    required String title,
    IconData? icon, // Icon is now optional
    Widget? leading, // Added leading for text
    String? trailingText, // Added trailingText for custom text
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
            : Icon(Icons.arrow_forward_ios,
                color: Colors.blueGrey[
                    700]), // Default to arrow icon if no trailing text is provided
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
