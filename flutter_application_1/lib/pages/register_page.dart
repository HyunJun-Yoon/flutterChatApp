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

  final provinces = [
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
  ];

  final gyunggi = [
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

  final gangwon = [
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

  final gyungnam = [
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

  final gyungbuk = [
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

  final choongnam = [
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

  final choongbuk = [
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

  final geonnam = [
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

  final geonbuk = [
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

  final jeju = ['제주시', '서귀포시'];

  final seoul = [
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

  final busan = [
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

  final daegu = [
    '중구',
    '서구',
    '동구',
    '남구',
    '북구',
    '수성구',
    '달서구',
    '달성군',
    '군위군',
  ];

  final incheon = [
    '중구',
    '동구',
    '미추홀구',
    '연수구',
    '남동구',
    '부평구',
    '계양구',
    '서구',
    '강화군',
    '옹진군',
  ];
  final gwangju = [
    '북구',
    '동구',
    '서구',
    '남구',
    '광산구',
  ];
  final daegeon = [
    '중구',
    '동구',
    '서구',
    '유성구',
    '대덕구',
  ];
  final ulsan = [
    '중구',
    '남구',
    '동구',
    '북구',
    '울주군',
  ];

  final nothingToSelect = [
    '선택할 시/구가 없습니다.',
  ];

  String? provinceValue = null;
  String? cityValue = null;
  List<String> cities = ['도를 먼저 선택해주세요'];
  String? guValue = null;
  String? email, password, name, country, province, city, ward;
  File? selectedImage;
  IconLabel? selectedIcon;
  bool isLoading = false;

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
          vertical: 20.0,
        ),
        child: Column(
          children: [
            _headerText(),
            if (!isLoading) _registerForm(),
            if (!isLoading) _loginAnAccountLink(),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
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
      height: MediaQuery.sizeOf(context).height * 0.60,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: _registerFormKey,
        child: ListView(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _pfpSelectionField(),
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
            _registerButton(),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
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
                            pfpURL: pfpURL),
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
                          pfpURL: ""),
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
          )),
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
    return Expanded(
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
