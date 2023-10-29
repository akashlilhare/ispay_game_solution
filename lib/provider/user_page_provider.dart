import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_user.dart';
import '../provider/authentication_provider.dart';
import '../services/database_service.dart';
import '../services/navigation_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import '../models/chat.dart';
import '../pages/chat_page.dart';

class UserPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;
  late DatabaseService _database;
  late NavigationService _navigation;

  List<ChatUser>? users;
  late List<ChatUser> _selectedUsers;

  List<ChatUser> get selectedUsers {
    return _selectedUsers;
  }

  UserPageProvider(this._auth) {
    _selectedUsers = [];
    _database = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    getUser();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void getUser({String? name}) async {
    _selectedUsers = [];
    try {
      _database.getUsers(name: name ?? "").then(
            (_snapshot) {
              users = _snapshot.docs.map(
                (_doc) {
              Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;
              _data["uid"] = _doc.id;
              return ChatUser.fromJson(_data);
            },
          ).cast<ChatUser>().toList();
          notifyListeners();
        },
      );
    } catch (e) {
      log("error getting users...");
      log(e.toString());
    }
  }

  void updateSelectedUsers(ChatUser _user){
    if(_selectedUsers.contains(_user)){
      _selectedUsers.remove(_user);
    }else{
      _selectedUsers.add(_user);
    }
    notifyListeners();
  }

  void unSelectAll(){
    _selectedUsers = [];
  }

  void createChat() async{
    try{
      //Create Chat
      List<String> _membersIds =
      _selectedUsers.map((_user) => _user.uid).toList();
      _membersIds.add(_auth.user.uid);
      bool _isGroup = _selectedUsers.length > 1;
      DocumentReference? _doc = await _database.creteChat(
        {
          "is_group": _isGroup,
          "is_activity": false,
          "members": _membersIds,
        },
      );

      //Navigate To Chat Page
      List<ChatUser> _members = [];
      for (var _uid in _membersIds) {
        DocumentSnapshot _userSnapshot = await _database.getUser(_uid);
        Map<String, dynamic> _userData =
        _userSnapshot.data() as Map<String, dynamic>;
        _userData["uid"] = _userSnapshot.id;
        _members.add(
          ChatUser.fromJson(
            _userData,
          ),
        );
      }
      log("here  ");
      ChatPage _chatPage = ChatPage(
        chat: Chat(
            uid: _doc!.id,
            currentUserUid: _auth.user.uid,
            members: _members,
            messages: [],
            activity: false,
            group: _isGroup),
      );
      _selectedUsers = [];
      notifyListeners();
      _navigation.navigateToPage(_chatPage);

    }catch(e){
      log("Error creating chat...");
      log(e.toString());
    }
  }
}
