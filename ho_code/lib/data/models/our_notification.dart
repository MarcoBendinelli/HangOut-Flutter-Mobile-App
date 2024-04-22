// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';

class OurNotification {
  final List<String> userIds;
  final String notificationId;
  final String thingToOpenId;
  final String thingToNotifyName;
  final String dateHour;
  final int timestamp;
  final String sourceName;
  final String eventCategory;
  final String chatMessage;
  final bool public;

  OurNotification(
      {required this.notificationId,
      required this.userIds,
      required this.thingToOpenId,
      required this.thingToNotifyName,
      required this.sourceName,
      required this.dateHour,
      required this.timestamp,
      required this.chatMessage,
      required this.eventCategory,
      required this.public});

  factory OurNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return OurNotification(
      notificationId: snapshot.id,
      userIds: List.from(data?['user_ids']),
      thingToOpenId: data?['thing_to_open_id'],
      thingToNotifyName: data?['thing_to_notify_name'],
      eventCategory: data?['event_category'],
      sourceName: data?['source_name'],
      dateHour: data?['date_hour'],
      timestamp: data?["time_stamp"],
      chatMessage: data?["chat_message"],
      public: data?["public"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (userIds != null) "user_ids": userIds,
      if (thingToOpenId != null) "thing_to_open_id": thingToOpenId,
      if (thingToNotifyName != null) "thing_to_notify_name": thingToNotifyName,
      if (eventCategory != null) "event_category": eventCategory,
      if (sourceName != null) "source_name": sourceName,
      if (dateHour != null) "date_hour": dateHour,
      if (timestamp != null) "time_stamp": timestamp,
      if (chatMessage != null) "chat_message": chatMessage,
      if (public != null) "public": public
    };
  }

  static OurNotification fromSnapshot(DocumentSnapshot snap) {
    return OurNotification(
        notificationId: snap.id,
        userIds: List.from(snap['user_ids']),
        thingToOpenId: snap['thing_to_open_id'],
        thingToNotifyName: snap['thing_to_notify_name'],
        sourceName: snap['source_name'],
        dateHour: snap['date_hour'],
        timestamp: snap['time_stamp'],
        chatMessage: snap['chat_message'],
        eventCategory: snap['event_category'],
        public: snap['public']);
  }

  @override
  String toString() =>
      '{ notificationId : $notificationId, userIds : $userIds, thingToOpenId : $thingToOpenId, thingToNotifyName : $thingToNotifyName, eventCategory : $eventCategory, chatMessage : $chatMessage, source_name : $sourceName, date_hour : $dateHour, public : $public';
}
