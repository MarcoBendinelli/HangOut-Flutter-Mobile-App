// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';

class NewGroupOrEventNotification {
  final List<String> usersId;
  final String notificationId;
  final String thingToJoinId;
  final String thingToJoinName;
  final String dateHour;
  final int timestamp;
  final String sourceName;
  final String? eventCategory;

  NewGroupOrEventNotification(
      {required this.notificationId,
      required this.usersId,
      required this.thingToJoinId,
      required this.thingToJoinName,
      required this.sourceName,
      required this.dateHour,
      required this.timestamp,
      this.eventCategory});

  factory NewGroupOrEventNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return NewGroupOrEventNotification(
      notificationId: snapshot.id,
      usersId: List.from(data?['users_id']),
      thingToJoinId: data?['thing_to_join_id'],
      thingToJoinName: data?['thing_to_join_name'],
      eventCategory: data?['event_category'],
      sourceName: data?['source_name'],
      dateHour: data?['date_hour'],
      timestamp: data?["time_stamp"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (usersId != null) "users_id": usersId,
      if (thingToJoinId != null) "thing_to_join_id": thingToJoinId,
      if (thingToJoinName != null) "thing_to_join_name": thingToJoinName,
      if (eventCategory != null) "event_category": eventCategory,
      if (sourceName != null) "source_name": sourceName,
      if (dateHour != null) "date_hour": dateHour,
      if (timestamp != null) "time_stamp": timestamp,
    };
  }

  static NewGroupOrEventNotification fromSnapshot(DocumentSnapshot snap) {
    String eventCategoryFromSnap = "";
    NewGroupOrEventNotification group;

    try {
      eventCategoryFromSnap = snap['event_category'];
      group = NewGroupOrEventNotification(
        usersId: List.from(snap['users_id']),
        thingToJoinId: snap['thing_to_join_id'],
        thingToJoinName: snap['thing_to_join_name'],
        eventCategory: eventCategoryFromSnap,
        sourceName: snap["source_name"],
        notificationId: snap.id,
        dateHour: snap["date_hour"],
        timestamp: snap["time_stamp"],
      );
    } catch (e) {
      group = NewGroupOrEventNotification(
          usersId: List.from(snap['users_id']),
          thingToJoinId: snap['thing_to_join_id'],
          thingToJoinName: snap['thing_to_join_name'],
          sourceName: snap["source_name"],
          notificationId: snap.id,
          dateHour: snap["date_hour"],
          timestamp: snap["time_stamp"]);
    }

    return group;
  }

  @override
  String toString() =>
      '{ usersId : $usersId, thingToJoinId : $thingToJoinId, thingToJoinName : $thingToJoinName, eventCategory : $eventCategory, source_name : $sourceName, date_hor: $dateHour';
}
