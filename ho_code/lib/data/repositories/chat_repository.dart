import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hang_out_app/data/models/message.dart';

class ChatRepository {
  final FirebaseFirestore _db;

  ChatRepository({FirebaseFirestore? firebaseFirestore})
      : _db = firebaseFirestore ?? FirebaseFirestore.instance;

  /// To get the chat of the group with id equal to groupId
  Stream<List<Message>> getTheChatOfTheGroupWithId({required String groupId}) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection("chat")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromFirestore(doc, null))
          .toList();
    });
  }

  /// To get the chat of the event with id equal to groupId
  Stream<List<Message>> getTheChatOfTheEventWithId({required String eventId}) {
    return _db
        .collection('events')
        .doc(eventId)
        .collection("chat")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromFirestore(doc, null))
          .toList();
    });
  }

  /// To send a Text message in the chat of the current group
  sendTextMessageInTheGroup(
      {required TextMessage message, required String groupId}) async {
    final chatGroupRef = _db
        .collection("groups")
        .doc(groupId)
        .collection("chat")
        .withConverter(
          fromFirestore: Message.fromFirestore,
          toFirestore: (Message message, options) => message.toMap(),
        )
        .doc();

    await chatGroupRef.set(message);
  }

  /// To send a Text message in the chat of the current event
  sendTextMessageInTheEvent(
      {required TextMessage message, required String eventId}) async {
    final chatGroupRef = _db
        .collection("events")
        .doc(eventId)
        .collection("chat")
        .withConverter(
          fromFirestore: Message.fromFirestore,
          toFirestore: (Message message, options) => message.toMap(),
        )
        .doc();

    await chatGroupRef.set(message);
  }
}
