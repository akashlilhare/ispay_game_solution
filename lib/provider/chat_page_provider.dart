import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/chat_message.dart';
import '../provider/authentication_provider.dart';
import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';
import '../services/media_service.dart';
import '../services/navigation_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;
  bool imageUploading = false;

  AuthenticationProvider _auth;
  ScrollController _messageListViewController;

  String chatId;
  List<ChatMessage>? messages;

  late StreamSubscription _messageStream;
  late StreamSubscription _keyboardStream;
  late KeyboardVisibilityController _keyboardVisibilityController;

  String? _message;

  String get message {
    return _message!;
  }

  set message(String _value) {
    _message = _value;
  }

  ChatPageProvider(this.chatId, this._auth, this._messageListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _keyboardVisibilityController = KeyboardVisibilityController();
    listenToKeyboardChanges();
    listenToMessage();
  }

  @override
  void dispose() {
    _messageStream.cancel();
    super.dispose();
  }

  void listenToMessage() {
    try {
      _messageStream = _db.steamMessageForChat(chatId).listen((_snapshot) {
        List<ChatMessage> _message = _snapshot.docs.map(
          (_m) {
            Map<String, dynamic> _messages = _m.data() as Map<String, dynamic>;
            return ChatMessage.fromJson(_messages);
          },
        ).toList();
        messages = _message;
        notifyListeners();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          log("outside call");
          if (_messageListViewController.hasClients) {
            log("inside call");
            _messageListViewController.jumpTo(
                _messageListViewController.position.maxScrollExtent + 200);
          }
        });
      });
    } catch (e) {}
  }

  void listenToKeyboardChanges() {
    _keyboardStream = _keyboardVisibilityController.onChange.listen((_event) {
      _db.updateChatData(chatId, {"is_activity": _event});
    });
  }

  sendGameMessage({required String message}) {
    print(message);

    ChatMessage messageToSend = ChatMessage(
      senderId: _auth.user.uid,
      type: MessageType.text,
      content: message,
      sentTime: DateTime.now(),
    );
    _db.addMessageToChat(chatId, messageToSend);
  }

  sendGameImageMessage({required String filePath}) async {
    try {
      imageUploading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        log("outside call");

        if (_messageListViewController.hasClients) {
          log("inside call");
          _messageListViewController.jumpTo(
              _messageListViewController.position.maxScrollExtent + 200);
        }
      });
      notifyListeners();
      //  PlatformFile? _file = await _media.pickImageFromLibrary();

      String? downloadURL = await _storage.saveChatImageToStorage(
          chatId, _auth.user.uid, filePath);

      ChatMessage _messageToSend = ChatMessage(
        senderId: _auth.user.uid,
        type: MessageType.image,
        content: downloadURL!,
        sentTime: DateTime.now(),
      );
      _db.addMessageToChat(chatId, _messageToSend);
    } catch (e) {
      print(e);
    } finally {
      imageUploading = false;
      notifyListeners();
    }
  }

  Future uploadImageToFirebaseStorage(
      Uint8List imageData, String imageName) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final Reference ref = storage
          .ref()
          .child(imageName); // Create a reference to the image file
      final UploadTask uploadTask = ref.putData(imageData);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      ChatMessage messageToSend = ChatMessage(
        senderId: _auth.user.uid,
        type: MessageType.image,
        content: downloadUrl,
        sentTime: DateTime.now(),
      );
      _db.addMessageToChat(chatId, messageToSend);
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void sendTextMessage() {
    if (_message != null) {
      ChatMessage _messageToSend = ChatMessage(
        senderId: _auth.user.uid,
        type: MessageType.text,
        content: _message!,
        sentTime: DateTime.now(),
      );
      _db.addMessageToChat(chatId, _messageToSend);
    }
  }

  void sendImageMessage() async {
    try {
      imageUploading = true;
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        log("outside call");

        if (_messageListViewController.hasClients) {
          log("inside call");
          _messageListViewController.jumpTo(
              _messageListViewController.position.maxScrollExtent + 200);
        }
      });
      notifyListeners();
      PlatformFile? _file = await _media.pickImageFromLibrary();
      if (_file != null) {
        String? downloadURL = await _storage.saveChatImageToStorage(
            chatId, _auth.user.uid, _file.path ?? "");

        ChatMessage _messageToSend = ChatMessage(
          senderId: _auth.user.uid,
          type: MessageType.image,
          content: downloadURL!,
          sentTime: DateTime.now(),
        );
        _db.addMessageToChat(chatId, _messageToSend);
      }
    } catch (e) {
      print(e);
    } finally {
      imageUploading = false;
      notifyListeners();
    }
  }

  void deleteChat() {
    goBack();
    _db.deleteChat();
  }

  void goBack() {
    _navigation.goBack();
  }
}
