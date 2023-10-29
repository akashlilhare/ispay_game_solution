import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

const String USER_COLLECTION = "User";

class CloudStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CloudStorageService() {}

  Future<String?> saveUserImageToStorage(
      String _uid, PlatformFile _file) async {
    try {
      log("images/users/$_uid/profile.${_file.extension}");

      Reference _ref =
          _storage.ref().child("images/users/$_uid/profile.${_file.extension}");
      UploadTask _task = _ref.putFile(File(_file.path!));

      return await _task.then((_result) {
        return _result.ref.getDownloadURL();
      });
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<String?> saveChatImageToStorage(
      String _chatId, String _userId, String path) async {
    try {
      Reference _ref = _storage.ref().child(
          "image/chat/$_chatId/${_userId}${Timestamp.now().microsecondsSinceEpoch}.png");
      UploadTask _task = _ref.putFile(File(path));
      return await _task.then((_result) => _result.ref.getDownloadURL());
    } catch (e) {
      log(e.toString());
    }
    return null;
  }
}
