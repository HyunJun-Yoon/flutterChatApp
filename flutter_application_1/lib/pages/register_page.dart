import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/consts.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/services/alert_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_application_1/services/media_service.dart';
import 'package:flutter_application_1/services/navigation_service.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:flutter_application_1/widgets/custom_form_field.dart';
import 'package:get_it/get_it.dart';

enum IconLabel {
  smile('Smile', Icons.sentiment_satisfied_outlined),
  cloud(
    'Cloud',
    Icons.cloud_outlined,
  ),
  brush('Brush', Icons.brush_outlined),
  heart('Heart', Icons.favorite);

  const IconLabel(this.label, this.icon);
  final String label;
  final IconData icon;
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  final TextEditingController iconController = TextEditingController();

  late AuthService _authService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AlertService _alertService;

  String? provinceValue = null;
  String? cityValue = null;
  List<String> cities = ['도를 먼저 선택해주세요'];
  String? guValue = null;
  String? email, password, name, country, province, city, ward;
  File? selectedImage;
  IconLabel? selectedIcon;
  bool isLoading = false;
  List<String>? chatId = [];

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 10.0,
        ),
        child: Column(
          children: [
            _headerText(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _registerForm(),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            if (!isLoading) _registerButton(),
            if (!isLoading) _loginAnAccountLink(),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: const Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "회원가입",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              "회원가입을 위해 정보를 입력해주세요.",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ));
  }

  Widget _registerForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height *
          0.7, // Adjust this value to your preference
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.0,
      ),
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            // Add an Expanded widget here to center the profile icon
            Expanded(
              flex: 1,
              child: Center(
                child: _pfpSelectionField(),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView(
                children: [
                  CustomFormField(
                    hintText: "닉네임",
                    height: MediaQuery.sizeOf(context).height * 0.1,
                    validationRegEx: NAME_VALIDATION_REGEX,
                    onSaved: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                  ),
                  CustomFormField(
                    hintText: "이메일",
                    height: MediaQuery.sizeOf(context).height * 0.1,
                    validationRegEx: EMAIL_VALIDATION_REGEX,
                    onSaved: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  CustomFormField(
                    hintText: "비밀번호",
                    height: MediaQuery.sizeOf(context).height * 0.1,
                    validationRegEx: PASSWORD_VALIDATION_REGEX,
                    obscureText: true,
                    onSaved: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                  _province(),
                  _city(cities),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: MaterialButton(
          color: Theme.of(context).colorScheme.primary,
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            try {
              if (_registerFormKey.currentState?.validate() ?? false) {
                _registerFormKey.currentState?.save();
                bool result = await _authService.signup(email!, password!);
                if (result) {
                  if (selectedImage != null) {
                    String? pfpURL = await _storageService.uploadUserPfp(
                      file: selectedImage!,
                      uid: _authService.user!.uid,
                    );
                    if (pfpURL != null) {
                      await _databaseService.createUserProfile(
                        userProfile: UserProfile(
                          uid: _authService.user!.uid,
                          name: name,
                          province: provinceValue,
                          city: cityValue,
                          pfpURL: pfpURL,
                          grade: 3,
                          numberOfTransaction: 0,
                          totalTransaction: 0,
                          chatId: [],
                        ),
                      );
                      _alertService.showToast(
                        text: "회원가입이 완료되었습니다.",
                        icon: Icons.check,
                      );
                      _navigationService.goBack();
                      _navigationService.pushReplacementNamed("/transaction");
                    } else {
                      throw Exception("프로필 사진 등록을 할 수 없습니다.");
                    }
                  } else {
                    await _databaseService.createUserProfile(
                      userProfile: UserProfile(
                        uid: _authService.user!.uid,
                        name: name,
                        province: provinceValue,
                        city: cityValue,
                        pfpURL: "",
                        grade: 3,
                        numberOfTransaction: 0,
                        totalTransaction: 0,
                        chatId: [],
                      ),
                    );
                    _alertService.showToast(
                      text: "회원가입이 완료되었습니다.",
                      icon: Icons.check,
                    );
                    _navigationService.goBack();
                    _navigationService.pushReplacementNamed("/transaction");
                  }
                } else {
                  throw Exception("회원가입을 할 수 없습니다.");
                }
              }
            } catch (e) {
              print(e);
              _alertService.showToast(
                text: "회원가입에 실패하였습니다. 다시 시도 해주세요.",
                icon: Icons.error,
              );
            }
            setState(() {
              isLoading = false;
            });
          },
          child: const Text(
            "회원가입",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
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
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
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
                borderRadius: BorderRadius.circular(5)),
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white))),
              hint: Text("시/도를 선택해주세요"),
              //value: dropdownvalue,
              items: provinces
                  .map((e) => DropdownMenuItem(
                        child: Text(e),
                        value: e,
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  provinceValue = val as String;
                  if (provinceValue == '경기도') {
                    cities = gyunggi;
                  } else if (provinceValue == '강원도') {
                    cities = gangwon;
                  } else if (provinceValue == '경상남도') {
                    cities = gyungnam;
                  } else if (provinceValue == '경상북도') {
                    cities = gyungbuk;
                  } else if (provinceValue == '충청남도') {
                    cities = choongnam;
                  } else if (provinceValue == '충청북도') {
                    cities = choongbuk;
                  } else if (provinceValue == '전라남도') {
                    cities = geonnam;
                  } else if (provinceValue == '전라북도') {
                    cities = geonbuk;
                  } else if (provinceValue == '제주도') {
                    cities = jeju;
                  } else if (provinceValue == '서울특별시') {
                    cities = seoul;
                  } else if (provinceValue == '부산광역시') {
                    cities = busan;
                  } else if (provinceValue == '대구광역시') {
                    cities = daegu;
                  } else if (provinceValue == '인천광역시') {
                    cities = incheon;
                  } else if (provinceValue == '광주광역시') {
                    cities = gwangju;
                  } else if (provinceValue == '대전광역시') {
                    cities = daegeon;
                  } else if (provinceValue == '울산광역시') {
                    cities = ulsan;
                  } else if (provinceValue == '세종특별자치시') {
                    cities = nothingToSelect;
                  }
                });
              },
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
            child: DropdownButtonFormField(
              hint: Text("구/시를 선택해주세요"),
              //value: dropdownvalue,
              items: cities
                  .map((e) => DropdownMenuItem(
                        child: Text(e),
                        value: e,
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  cityValue = val as String;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginAnAccountLink() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("계정이 이미 있으신가요?"),
          GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: const Text(
              "로그인하기",
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
