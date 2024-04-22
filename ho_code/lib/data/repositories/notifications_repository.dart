import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hang_out_app/data/models/our_notification.dart';

class NotificationsRepository {
  final FirebaseFirestore _db;

  NotificationsRepository({FirebaseFirestore? firebaseFirestore})
      : _db = firebaseFirestore ?? FirebaseFirestore.instance;

  Future<void> addNewNotification(
      {required OurNotification notification}) async {
    final notificationRef = _db
        .collection("notifications")
        .withConverter(
            fromFirestore: OurNotification.fromFirestore,
            toFirestore: (OurNotification notification, options) =>
                notification.toMap())
        .doc();

    if (notification.chatMessage != "") {
      try {
        String notificationId = await _db
            .collection("notifications")
            .where("thing_to_open_id", isEqualTo: notification.thingToOpenId)
            .get()
            .then(
          (querySnapshot) {
            return querySnapshot.docs
                .where((e) => e["chat_message"] != "")
                .first
                .id;
          },
          onError: (e) => debugPrint("Error completing: $e"),
        );
        await _db
            .collection("notifications")
            .doc(notificationId)
            .update(notification.toMap());
        return;
      } catch (e) {
        debugPrint("No message notification to update");
      }
    }

    await notificationRef.set(notification);
    await notificationRef.update({'id': notificationRef.id});
  }

  Future<void> removeUserFromNotification(
      {required String idUser, required String idNotification}) async {
    try {
      /// The notification is seen by the user so I can remove him/her
      await _db.collection("notifications").doc(idNotification).update({
        "user_ids": FieldValue.arrayRemove([idUser]),
      });

      /// Get the notification object to see if the array of user is empty
      final ref =
          _db.collection("notifications").doc(idNotification).withConverter(
                fromFirestore: OurNotification.fromFirestore,
                toFirestore: (OurNotification notification, _) =>
                    notification.toMap(),
              );

      final docSnap = await ref.get();
      OurNotification notification = docSnap.data()!;

      if (notification.userIds.isEmpty) {
        /// All the users have seen the notification, thus, I can remove it
        deleteNotification(idNotification);
      }
    } catch (e) {
      debugPrint("The notification is already deleted");
    }
  }

  Future<void> deleteNotification(String idNotification) async {
    await _db.collection("notifications").doc(idNotification).delete();
  }

  Future<Stream<List<OurNotification>>> getNotifications(String userId) async {
    return _db
        .collection('notifications')
        .where("user_ids", arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OurNotification.fromSnapshot(doc))
          .toList();
    });
  }
}
