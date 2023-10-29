import '../models/chat_message.dart';
import '../models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../models/chat.dart';
import '../provider/authentication_provider.dart';
import '../provider/chats_page_provider.dart';
import '../services/navigation_services.dart';
import '../widgets/custom_list_tile.dart';
import '../widgets/top_bar.dart';
import 'chat_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late AuthenticationProvider _auth;
  late ChatsPageProvider _pageProvider;
  late NavigationService _navigation;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Consumer<ChatsPageProvider>(builder: (context, data, _) {
      _pageProvider = data;

      List<Chat>? _chats = _pageProvider.chats;
      return Scaffold(
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
                        Text(choice),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ], title: "I-spy", context: context),
          body: (() {
            if (_chats != null) {
              if (_chats.isNotEmpty) {
                return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _chats.length,
                        itemBuilder: (context, index) {
                          return buildChatTile(_chats[index]);
                        }));
              } else {
                return Center(
                    child: Text("No Chats Found",
                        style: TextStyle(color: Colors.black54)));
              }
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              );
            }
          })());
    });
  }

  buildChatTile(Chat _chat) {
    List<ChatUser> _recepients = _chat.recepients();
    bool _isActive = _recepients.any((_d) => _d.wasRecentlyActive());
    String _subtitleText = "";
    if (_chat.messages.isNotEmpty) {
      _subtitleText = _chat.messages.first.type == MessageType.image
          ? "Media Attachment"
          : _chat.messages.first.content;
    }
    return Column(
      children: [
        CustomListTile(
          height: _deviceHeight * 0.10,
          title: _chat.title(),
          imagePath: _chat.imageUrl(),
          onTap: () {
            _navigation.navigateToPage(ChatPage(chat: _chat));
          },
          subtitle: _subtitleText,
          isActive: _isActive,
          isActivity: _chat.activity,
        ),
        Container(
          height: .5,
          width: double.infinity,
          color: Colors.blue.withOpacity(.2),
        )
      ],
    );
  }
}
