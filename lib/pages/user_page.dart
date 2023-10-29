import 'dart:developer';

import '../provider/authentication_provider.dart';
import '../provider/chats_page_provider.dart';
import '../provider/user_page_provider.dart';
import '../widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../models/chat.dart';
import '../models/chat_user.dart';
import '../services/navigation_services.dart';
import '../widgets/custom_list_tile.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/top_bar.dart';
import 'chat_page.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UsersPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  final TextEditingController _searchInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    _auth = Provider.of<AuthenticationProvider>(context);

    return Consumer<UserPageProvider>(builder: (context, pageData, _) {
      NavigationService _navigation = GetIt.instance.get<NavigationService>();

      return Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Visibility(
              visible: pageData.selectedUsers.isNotEmpty,
              child: RoundedButton(
                child: Text(
                  pageData.selectedUsers.length == 1
                      ? "Play With ${pageData.selectedUsers.first.name}"
                      : "Create Group Chat",
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
                height: 50,
                onPressed: () {
                  log("+++++++++++++++++++++++++++++++++++++");

                  if (pageData.selectedUsers.isNotEmpty) {
                    ChatUser currUser = pageData.selectedUsers[0];
                    log(currUser.uid + ' uid');
                    List<Chat>? _chats =
                        Provider.of<ChatsPageProvider>(context, listen: false)
                            .chats;

                    if (_chats != null) {
                      for (var chat in _chats) {
                        log("here");
                        if (!chat.group) {
                          for (var member in chat.members) {
                            log(member.uid);
                            if (member.uid == currUser.uid) {
                              log("here");
                              _navigation.navigateToPage(ChatPage(chat: chat));
                              pageData.unSelectAll();
                              return;
                            }
                          }
                        }
                      }
                    }
                    pageData.createChat();
                  }
                },
                width: double.infinity,
              ),
            ),
          ),
          appBar: appBar([
            PopupMenuButton<String>(
              onSelected: (_) {
                _auth.logout();
              },
              itemBuilder: (BuildContext context) {
                return {'Logout'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(
                          width: 18,
                        ),
                        Text(
                          choice,
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ], title: "All Users", context: context),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SizedBox(
                  height: 12,
                ),
                Container(
                  child: CustomTextField(
                    controller: _searchInputController,
                    hintText: "Search...",
                    obscureText: false,
                    onEditingComplete: (_value) {
                      pageData.getUser(name: _value);
                    },
                    icon: Icons.search,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                _userList(pageData: pageData),
              ],
            ),
          ));
    });
  }

  Widget _userList({required UserPageProvider pageData}) {
    List<ChatUser>? _users = pageData.users;

    if (_users != null) {
      if (_users.isEmpty) {
        return Center(
            child: Text(
          "No user found",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ));
      } else {
        return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              ChatUser _currUser = _users[index];
              return _auth.user.uid == _currUser.uid
                  ? Container()
                  : CustomListViewTile(
                      isSelected: pageData.selectedUsers.contains(_currUser),
                      title: _currUser.name,
                      onTap: () {
                        pageData.updateSelectedUsers(_currUser);
                      },
                      dateTime: _currUser.lastActive,
                      isActive: _currUser.wasRecentlyActive(),
                      imagePath: _currUser.imageURL,
                    );
            });
      }
    } else {
      return Center(
          child: CircularProgressIndicator(
        color: Colors.white,
      ));
    }
  }
}
