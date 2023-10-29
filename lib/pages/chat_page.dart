import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:ispy_game/services/database_service.dart';

import '../models/chat.dart';
import '../models/chat_message.dart';
import '../provider/authentication_provider.dart';
import '../provider/chat_page_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/rounded_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_chat_bubble.dart';
import 'edit_image_page.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  const ChatPage({Key? key, required this.chat}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;
  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messageListViewController;
  bool gameOver = false;

  final ImagePicker picker = ImagePicker();
  XFile? selectedImage;
  int noCount = 0;
  bool mainPlayer = false;

  @override
  void initState() {
    _messageFormState = GlobalKey<FormState>();
    _messageListViewController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ChatPageProvider(
                widget.chat.uid, _auth, _messageListViewController))
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Consumer<ChatPageProvider>(builder: (context, data, _) {
      return Scaffold(
          bottomNavigationBar: (data.messages != null &&
                  data.messages!.length.isOdd &&
                  data.messages!.length > 2 &&
                  mainPlayer)
              ? getVerifyButton(data)
              : null,
          appBar: AppBar(
            elevation: .5,
            actions: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8).copyWith(right: 8),
                child: ElevatedButton(
                  onPressed: () async {
                    await DatabaseService().deleteChat();
                    Navigator.of(context).pop();
                  },
                  child: Text("Quit"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              )
            ],
            iconTheme: IconThemeData(color: Colors.black),
            leadingWidth: 30,
            title: Row(
              children: [
                RoundedImageNetwork(
                  size: 40,
                  imagePath: widget.chat.imageUrl(),
                ),
                SizedBox(
                  width: 18,
                ),
                Flexible(
                    child: Text(
                  widget.chat.title(),
                  style: TextStyle(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                )),
              ],
            ),
          ),
          body: _messageListView(data));
    });
  }

  Widget _messageListView(ChatPageProvider _pageProvider) {
    if (_pageProvider.messages != null) {
      if (_pageProvider.messages!.isNotEmpty) {
        return ListView.builder(
            padding: EdgeInsets.only(bottom: 30),
            controller: _messageListViewController,
            physics: BouncingScrollPhysics(),
            itemCount: _pageProvider.messages!.length,
            itemBuilder: (context, index) {var _message = _pageProvider.messages![index];
              bool _isOwnMessage = _message.senderId == _auth.user.uid;
              return Column(
                crossAxisAlignment: _isOwnMessage
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  IgnorePointer(
                    ignoring: gameOver,
                    child: CustomChatBubble(
                      mainImage: _pageProvider.messages![0].content,
                      noCount: noCount,
                      provider: _pageProvider,
                      player: mainPlayer,
                      sender: this
                          .widget
                          .chat
                          .members
                          .where((_m) => _m.uid == _message.senderId)
                          .first,
                      isOwnMessage: _isOwnMessage,
                      message: _message,
                    ),
                  ),
                  if (index == _pageProvider.messages!.length - 1 &&
                      _pageProvider.imageUploading)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 18),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.grey.shade900,
                        ),
                        height: 200,
                        width: 150,
                        padding:
                            EdgeInsets.symmetric(horizontal: 65, vertical: 85),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                ],
              );
            });
      } else {
        return _buildStartGameTile(_pageProvider);
      }
    } else {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }
  }

  Widget _buildStartGameTile(ChatPageProvider _pageProvider) {
    return Center(
      child: Container(
        height: 110,
        width: _deviceWidth * .8,
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.blue.withOpacity(.1),
            borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            Text("Let's start the game"),
            SizedBox(
              height: 8,
            ),
            ElevatedButton(
                onPressed: () async {
                  TextEditingController spyController = TextEditingController();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);

                  if (image != null) {
                    bool? res = await showDialog(
                        context: context,
                        builder: (builder) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("I spy with my little eye a thing"),
                                TextField(
                                  controller: spyController,
                                  decoration: InputDecoration(
                                      hintText: "Describe color or shape"),
                                )
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text("Send")),
                            ],
                          );
                        });

                    if (res == true) {
                      await _pageProvider.sendGameImageMessage(
                          filePath: image.path);
                      await _pageProvider.sendGameMessage(
                          message: "I spy with my little eye a thing " +
                              spyController.text);
                      setState(() {
                        mainPlayer = true;
                      });
                    }
                  }
                },
                child: Text("Capture image"))
          ],
        ),
      ),
    );
  }

  Widget _sendMessageForm(ChatPageProvider _pageProvider) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          border: Border.all(color: Colors.black54, width: .2),
          borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Form(
        key: _messageFormState,
        child: Row(
          children: [
            SizedBox(
              width: 8,
            ),
            _messageTextField(_pageProvider),
            Spacer(),
            _sendImageButton(_pageProvider),
            _sendMessageButton(_pageProvider),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField(ChatPageProvider _pageProvider) {
    return SizedBox(
      width: _deviceWidth * 0.65,
      child: CustomTextFormField(
        validationMsg: "This field can't be empty",
        bgColor: Theme.of(context).inputDecorationTheme.fillColor!,
        textColor: Colors.black,
        hintText: "Enter message...",
        obscureText: false,
        onSaved: (String _value) {
          _pageProvider.message = _value;
        },
        regEx: r"[a-z]{1}",
      ),
    );
  }

  Widget _sendMessageButton(ChatPageProvider _pageProvider) {
    return InkWell(
      onTap: () {
        if (_messageFormState.currentState!.validate()) {
          _messageFormState.currentState!.save();
          _pageProvider.sendTextMessage();
          _messageFormState.currentState!.reset();
        }
      },
      child: Container(
        padding: EdgeInsets.only(left: 6, right: 18, top: 8, bottom: 8),
        child: Icon(
          Icons.send,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _sendImageButton(ChatPageProvider _pageProvider) {
    return Container(
      height: 55,
      padding: EdgeInsets.symmetric(vertical: 7),
      child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            _pageProvider.sendImageMessage();
          },
          child: Icon(
            Icons.camera_enhance,
            size: 22,
          )),
    );
  }

  Widget getVerifyButton(ChatPageProvider _pageProvider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Correct/ Incorrect",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            ElevatedButton(
                onPressed: () async {
                  await _pageProvider.sendGameMessage(message: "You win");
                },
                child: Text("Yes")),
            Spacer(),
            ElevatedButton(
                onPressed: () async {
                  setState(() {
                    noCount++;
                  });

                  if (noCount == 3) {
                    await _pageProvider.sendGameMessage(message: "You lose");
                    return;
                  }
                  await _pageProvider.sendGameMessage(
                      message: "Incorrect choice");
                },
                child: Text("No")),
          ],
        ),
      ],
    );
  }
}
