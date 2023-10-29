import 'dart:developer';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_sentiment/dart_sentiment.dart';
import 'package:ispy_game/pages/edit_image_page.dart';
import 'package:ispy_game/provider/chat_page_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../widgets/rounded_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/chat_user.dart';

class CustomChatBubble extends StatelessWidget {
  final bool isOwnMessage;
  final ChatMessage message;
  final ChatUser sender;
  final bool player;
  final String mainImage;
  final int noCount;
  final ChatPageProvider provider;

  const CustomChatBubble(
      {Key? key,
      required this.isOwnMessage,
        required this.mainImage,
      required this.message,
      required this.sender,
      required this.player,
      required this.noCount,
      required this.provider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ChatBubble(
          elevation: 0,
          clipper: ChatBubbleClipper1(
            type: isOwnMessage
                ? BubbleType.sendBubble
                : BubbleType.receiverBubble,
          ),
          alignment: isOwnMessage ? Alignment.topRight : Alignment.topLeft,
          margin: EdgeInsets.only(top: 24),
          backGroundColor: !isOwnMessage
              ? Theme.of(context).inputDecorationTheme.fillColor
              : Theme.of(context).primaryColor,
          child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !isOwnMessage
                      ? Container(
                          width: sender.name.length * 10,
                          child: Stack(
                            children: [
                              RoundedImageNetwork(
                                  key: UniqueKey(),
                                  imagePath: sender.imageURL,
                                  size: 18),
                              Positioned(
                                  left: 28,
                                  child: Text(
                                    sender.name,
                                    style: TextStyle(
                                      letterSpacing: -.2,
                                      fontSize: 13,
                                      color: isOwnMessage
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ))
                            ],
                          ),
                        )
                      : Container(
                          width: 0,
                        ),
                  if (!isOwnMessage)
                    SizedBox(
                      height: 8,
                    ),
                  message.type == MessageType.text
                      ? Text(
                          message.content,
                          style: TextStyle(
                              color:
                                  isOwnMessage ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        )
                      : InkWell(
                          onTap: () async {


                            if (!player ) {
                              Uint8List? imageFile = await Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return EditImagePage(image: mainImage);
                              }));

                              if (imageFile != null) {
                                provider.uploadImageToFirebaseStorage(
                                    imageFile, Uuid().v1());
                              }
                            }
                          },
                          // constraints:
                          //     BoxConstraints(maxHeight: 250, minHeight: 100),
                          child: CachedNetworkImage(
                            imageUrl: message.content,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    Shimmer.fromColors(
                              baseColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              highlightColor: Colors.grey.shade900,
                              child: Container(
                                height: 250,
                                width: 100,
                                child: Center(
                                    child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                )),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                  SizedBox(
                    height: 4,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 1.0),
                    child: Text(
                      DateFormat.jm().format(message.sentTime),
                      style: TextStyle(
                        color: isOwnMessage ? Colors.white60 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              )

              // Column(
              //   mainAxisSize: MainAxisSize.min,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [

              //     !isOwnMessage
              //         ?     SizedBox(height: 12,):Container(),
              //
              //

              //   ],
              // )
              ),
        ),
      ],
    );
  }
}
