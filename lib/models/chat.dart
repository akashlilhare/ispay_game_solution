import 'chat_message.dart';
import 'chat_user.dart';

class Chat {
  final String uid;
  final String currentUserUid;
  final bool activity;
  final bool group;
  final List<ChatUser> members;
  final List<ChatMessage> messages;

  late final List<ChatUser> _recepients;

  Chat(
      {required this.uid,
      required this.activity,
      required this.currentUserUid,
      required this.group,
      required this.messages,
      required this.members}) {
    _recepients = members.where((_i) => _i.uid != currentUserUid).toList();
  }

  List<ChatUser> recepients() {
    return _recepients;
  }

  String title() {
    return !group
        ? _recepients.first.name
        : _recepients.map((_user) => _user.name).join(", ");
  }

  String imageUrl(){
    return !group ? _recepients.first.imageURL: "https://www.iconpacks.net/icons/1/free-user-group-icon-296-thumb.png";
  }
}
