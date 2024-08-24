import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class RegisterItemPage extends StatefulWidget {
  const RegisterItemPage({super.key});

  @override
  _RegisterItemPageState createState() => _RegisterItemPageState();
}

class _RegisterItemPageState extends State<RegisterItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  final GetIt _getIt = GetIt.instance;
  List<File> _imageFiles = [];
  bool _isLoading = false;
  bool _isImageSectionVisible = true;
  late AuthService _authService;
  late User? loggedInUser = null;
  List<String>? chatId = [];
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

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();

    getUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
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
      chatId = (data['chatId'] as List<dynamic>?)?.cast<String>() ?? [];
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imageFiles = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _registerItem() async {
    if (_formKey.currentState!.validate() && _imageFiles.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Upload images using the uploadItemImages function
        String uid = loggedInUser!.uid;
        List<String>? imageUrls = await _storageService.uploadItemImages(
          files: _imageFiles,
          uid: uid,
        );

        if (imageUrls != null) {
          await FirebaseFirestore.instance.collection('items').add({
            'name': _nameController.text,
            'description': _descriptionController.text,
            'price': _priceController.text,
            'imageUrls': imageUrls, // Store image URLs
            'uid': uid,
            'createdAt': Timestamp.now(),
          });
        } else {
          // Handle upload failure (optional)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload images')),
          );
        }
      } catch (e) {
        print('Failed to register item: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register item')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 정보를 입력해주세요.')),
      );
    }
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.grey, size: 40),
                SizedBox(width: 16),
                Text(
                  '${_imageFiles.length}/10',
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        _imageFiles.isEmpty
            ? Container()
            : SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageFiles.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.file(
                        _imageFiles[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '상품 등록',
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageUploadSection(),
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '상품명',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    floatingLabelBehavior:
                        FloatingLabelBehavior.auto, // Enable label animation
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '상품명을 입력하세요';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: '상품 설명',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    floatingLabelBehavior:
                        FloatingLabelBehavior.auto, // Enable label animation
                  ),
                  maxLines: 7,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '상품 설명을 입력하세요';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: '가격',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    floatingLabelBehavior:
                        FloatingLabelBehavior.auto, // Enable label animation
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '가격을 입력하세요';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            '등록',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
