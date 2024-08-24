import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  StorageService() {}

  Future<String?> uploadUserPfp({
    required File file,
    required String uid,
  }) async {
    Reference fileRef = _firebaseStorage
        .ref('users/pfps')
        .child('$uid${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then(
      (p) {
        if (p.state == TaskState.success) {
          return fileRef.getDownloadURL();
        }
      },
    );
  }

  Future<List<String>?> uploadItemImages({
    required List<File> files,
    required String uid,
  }) async {
    List<String> downloadUrls = [];

    for (File file in files) {
      try {
        // Create a unique reference for each file
        Reference fileRef = _firebaseStorage.ref('items/images/$uid').child(
            '${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}');

        // Upload the file
        UploadTask task = fileRef.putFile(file);

        // Wait for the upload to complete
        TaskSnapshot snapshot = await task;

        // Check if upload was successful
        if (snapshot.state == TaskState.success) {
          try {
            // Retrieve the download URL after the upload is complete
            String downloadUrl = await fileRef.getDownloadURL();
            downloadUrls.add(downloadUrl);
          } catch (e) {
            print('Failed to get download URL for ${file.path}: $e');
          }
        } else {
          print('Upload failed for ${file.path}: ${snapshot.state}');
        }
      } catch (e) {
        print('Failed to upload image ${file.path}: $e');
      }
    }

    return downloadUrls.isNotEmpty ? downloadUrls : null;
  }

  Future<String?> uploadImageToChat(
      {required File file, required String chatID}) async {
    Reference fileRef = _firebaseStorage
        .ref('chats/$chatID')
        .child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then(
      (p) {
        if (p.state == TaskState.success) {
          return fileRef.getDownloadURL();
        }
      },
    );
  }
}
