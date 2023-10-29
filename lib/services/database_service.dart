import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

const String USER_COLLECTION = "Users";
const String CHAT_COLLECTION = "Chats";
const String MESSAGES_COLLECTION = "messages";

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService() {}

  Future<void> createUser(
      String _uid, String _email, String _imageURL, String _name) async {
    try {
      await _db.collection(USER_COLLECTION).doc(_uid).set({
        "email": _email,
        "image": _imageURL,
        "last_active": DateTime.now().toUtc(),
        "name": _name
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<DocumentSnapshot> getUser(String _uid) {
    return _db.collection(USER_COLLECTION).doc(_uid).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatsForUser(String _uid) {
    return _db
        .collection(CHAT_COLLECTION)
        .where(
          "members",
          arrayContains: _uid,
        )
        .snapshots();
  }

  Future<QuerySnapshot> getUsers({String? name}) {
    Query _query = _db.collection(USER_COLLECTION);
    if (name != null) {
      _query = _query
          .where("name", isGreaterThanOrEqualTo: name)
          .where("name", isLessThanOrEqualTo: name + "z");
    }
    return _query.get();
  }

  Future<QuerySnapshot> getLastMessageForChat(String _chatID) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(_chatID)
        .collection(MESSAGES_COLLECTION)
        .orderBy("sent_time", descending: true)
        .limit(1)
        .get();
  }

  Stream<QuerySnapshot> steamMessageForChat(String _chatId) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(_chatId)
        .collection(MESSAGES_COLLECTION)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> deleteChat() async {

    try {
      CollectionReference collectionReference = FirebaseFirestore.instance.collection(CHAT_COLLECTION);

      QuerySnapshot querySnapshot = await collectionReference.get();



      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      log("fail to delete message...");
      log(e.toString());
    }
  }

  Future<DocumentReference?> creteChat(Map<String, dynamic> _data) async {
    try {
      DocumentReference _chat =
          await _db.collection(CHAT_COLLECTION).add(_data);
      return _chat;
    } catch (e) {
      log("error creating chats 1");
      log(e.toString());
    }
  }

  Future<void> updateChatData(
      String _chatId, Map<String, dynamic> _data) async {
    try {
      await _db.collection(CHAT_COLLECTION).doc(_chatId).update(_data);
    } catch (e) {}
  }

  Future<void> quitGame(String _chatId) async {
    print(_chatId);
    try {
      await _db
          .collection(CHAT_COLLECTION)
          .doc(_chatId)
          .update({"messages": []});
    } catch (e) {}
  }

  Future<void> addMessageToChat(
      String _chatId, ChatMessage _chatMessage) async {
    try {
      await _db
          .collection(CHAT_COLLECTION)
          .doc(_chatId)
          .collection(MESSAGES_COLLECTION)
          .add(_chatMessage.toJson());
    } catch (e) {}
  }

  Future<void> updateUserLastSeenTime(String _uid) async {
    try {
      await _db
          .collection(USER_COLLECTION)
          .doc(_uid)
          .update({"last_active": DateTime.now().toUtc()});
    } catch (e) {
      log(e.toString());
    }
  }
}
