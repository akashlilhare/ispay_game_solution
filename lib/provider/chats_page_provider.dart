import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../provider/authentication_provider.dart';
import '../services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import '../models/chat.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';

class ChatsPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;
  late DatabaseService _db;
  List<Chat>? chats;

  late StreamSubscription _chatStream;

  ChatsPageProvider(this._auth) {
    _db = GetIt.instance.get<DatabaseService>();
    getChats();
  }

  @override
  void dispose() {
    _chatStream.cancel();
    super.dispose();
  }

  void getChats() async {
    try {
      _chatStream =
          _db.getChatsForUser(_auth.user.uid).listen((_snapshot) async {
            List<Chat>? allChat = await Future.wait(_snapshot.docs.map((_d) async {
          Map<String, dynamic> _chatData = _d.data();

          //Get Users In Chat
          List<ChatUser> _members = [];
          for (var _uid in _chatData["members"]) {
            DocumentSnapshot _userSnapshot = await _db.getUser(_uid);
            Map<String, dynamic> _userData =
                _userSnapshot.data() as Map<String, dynamic>;
            _userData["uid"] = _userSnapshot.id;
            _members.add(
              ChatUser.fromJson(_userData),
            );
          }
          //Get Last Message For Chat
          List<ChatMessage> _messages = [];
          QuerySnapshot _chatMessage = await _db.getLastMessageForChat(_d.id);
          if (_chatMessage.docs.isNotEmpty) {
            Map<String, dynamic> _messageData =
                _chatMessage.docs.first.data()! as Map<String, dynamic>;
            ChatMessage _message = ChatMessage.fromJson(_messageData);

            _messages.add(_message);
          }

          return Chat(
              uid: _d.id,
              activity: _chatData["is_activity"],
              currentUserUid: _auth.user.uid,
              group: _chatData["is_group"],
              members: _members,
              messages: _messages);
        }));
        if (allChat.isNotEmpty) {
          allChat.sort((e1, e2) {
            return Comparable.compare(
                DateTime.now().difference(e1.messages.first.sentTime),
                DateTime.now().difference(e2.messages.first.sentTime));
          });
        }

        chats = allChat;
        notifyListeners();
      });
    } catch (e) {
      log("error getting chats");
      log(e.toString());
    }
  }

}
