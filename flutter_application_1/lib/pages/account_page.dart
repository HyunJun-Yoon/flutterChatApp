import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/consts.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_application_1/services/media_service.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:flutter_application_1/services/alert_service.dart';
import 'package:flutter_application_1/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

class AccountSettingPage extends StatefulWidget {
  final String userName;
  final String userUid;
  final String userPFP;
  final String userProvince;
  final String userCity;
  final String userEmail;
  final grade;
  final totalTransaction;
  final numberOfTransaction;
  final chatId;
  final VoidCallback? onSettingsUpdated;

  const AccountSettingPage({
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
  State<AccountSettingPage> createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  final _formKey = GlobalKey<FormState>();
  final GetIt _getIt = GetIt.instance;
  String? provinceValue;
  String? cityValue;
  List<String> cities = ['도를 먼저 선택해주세요'];
  late DatabaseService _databaseService;
  late StorageService _storageService;
  late AlertService _alertService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool isLoading = false;
  var selectedImage;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _databaseService = _getIt.get<DatabaseService>();
    _storageService = _getIt.get<StorageService>();
    _alertService = _getIt.get<AlertService>();
    _navigationService = _getIt.get<NavigationService>();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
    provinceValue = widget.userProvince;
    cityValue = widget.userCity;
    _setCities(provinceValue.toString());
  }

  void _setCities(String province) {
    switch (province) {
      case '경기도':
        cities = gyunggi;
        break;
      case '강원도':
        cities = gangwon;
        break;
      case '경상남도':
        cities = gyungnam;
        break;
      case '경상북도':
        cities = gyungbuk;
        break;
      case '충청남도':
        cities = choongnam;
        break;
      case '충청북도':
        cities = choongbuk;
        break;
      case '전라남도':
        cities = geonnam;
        break;
      case '전라북도':
        cities = geonbuk;
        break;
      case '제주도':
        cities = jeju;
        break;
      case '서울특별시':
        cities = seoul;
        break;
      case '부산광역시':
        cities = busan;
        break;
      case '대구광역시':
        cities = daegu;
        break;
      case '인천광역시':
        cities = incheon;
        break;
      case '광주광역시':
        cities = gwangju;
        break;
      case '대전광역시':
        cities = daegeon;
        break;
      case '울산광역시':
        cities = ulsan;
        break;
      case '세종특별자치시':
        cities = nothingToSelect;
        break;
      default:
        cities = [];
    }

    // Clear cityValue if the new province has no cities
    if (cities.isEmpty || cities.contains('도를 먼저 선택해주세요')) {
      cityValue = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _province() {
    return Padding(
      padding: EdgeInsets.only(left: 0, right: 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: DropdownButtonHideUnderline(
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              value: provinceValue,
              items: provinces
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Row(
                          children: [
                            Icon(Icons.location_city,
                                color: const Color.fromARGB(
                                    255, 0, 0, 0)), // Add the icon
                            SizedBox(width: 10), // Space between icon and text
                            Text(e),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  provinceValue = val as String;
                  _setCities(provinceValue!);
                  cityValue =
                      null; // Clear the city value when changing the province
                });
              },
              itemHeight: 48, // Reduce the height of each item
            ),
          ),
        ),
      ),
    );
  }

  Widget _city(List<String> cities) {
    return Padding(
      padding: EdgeInsets.only(left: 0, right: 0, top: 15, bottom: 30),
      child: Align(
        alignment: Alignment.centerLeft,
        child: DropdownButtonHideUnderline(
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButtonFormField<String>(
              value: cityValue,
              items: cities
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Row(
                          children: [
                            Icon(Icons.location_city,
                                color: const Color.fromARGB(
                                    255, 0, 0, 0)), // Add the icon
                            SizedBox(width: 10), // Space between icon and text
                            Text(e),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  cityValue = val as String;
                });
              },
              itemHeight: 48, // Reduce the height of each item
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _pfpSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(widget.userPFP) as ImageProvider,
      ),
    );
  }

  void _saveAccountSettings() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      try {
        _formKey.currentState?.save();

        // Update profile picture if a new image has been selected
        String pfpURL = widget.userPFP;
        if (selectedImage != null) {
          String? newPfpURL = await _storageService.uploadUserPfp(
            file: selectedImage!,
            uid: widget.userUid,
          );
          if (newPfpURL != null) {
            pfpURL = newPfpURL;
          } else {
            throw Exception("프로필 사진 등록을 할 수 없습니다.");
          }
        }

        // Update user profile in the database
        await _databaseService.updateUserProfile(
          userProfile: UserProfile(
            uid: widget.userUid,
            name: _nameController.text,
            province: provinceValue,
            city: cityValue,
            pfpURL: pfpURL,
            grade: widget.grade,
            totalTransaction: widget.totalTransaction,
            numberOfTransaction: widget.numberOfTransaction,
            chatId: widget.chatId,
          ),
        );

        widget.onSettingsUpdated!();
        _alertService.showToast(
          text: "계정 정보가 업데이트되었습니다.",
          icon: Icons.check,
        );
        _navigationService.goBack();
      } catch (e) {
        print(e);
        _alertService.showToast(
          text: "계정 정보 업데이트에 실패하였습니다. 다시 시도 해주세요.",
          icon: Icons.error,
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('계정 설정', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _sectionTitle('프로필'),
              const SizedBox(height: 20),
              _pfpSelectionField(),
              const SizedBox(height: 20),
              _sectionTitle('닉네임'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: widget.userName,
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                style:
                    TextStyle(color: Colors.grey), // Change the font color here
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력하세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _sectionTitle('이메일'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: widget.userEmail,
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                style:
                    TextStyle(color: Colors.grey), // Change the font color here
              ),
              const SizedBox(height: 20),
              _sectionTitle('주거래 위치'),
              const SizedBox(height: 10),
              _province(),
              _city(cities),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAccountSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 194, 217, 247),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: const Text(
                  '저장하기',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Color.fromARGB(255, 16, 116, 197),
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
