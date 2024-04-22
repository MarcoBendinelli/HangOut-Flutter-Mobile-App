import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/models/user_data.dart';

class WidgetTestUtils {
  static final Event event1 = Event(
      category: "food",
      date: Timestamp.fromDate(DateTime.utc(2060, 5, 8, 16)),
      private: true,
      id: "event1Id",
      name: "event1",
      description: "description",
      location: const GeoPoint(0, 0),
      locationName: "locationName",
      photo: "",
      numParticipants: 1,
      creatorId: "user1Id",
      members: ["user1Id"]);
  static final Event event2 = Event(
      category: "food",
      date: Timestamp.fromDate(DateTime.utc(2060, 5, 8, 16)),
      private: true,
      id: "event1Id",
      name: "event2",
      description: "description",
      location: const GeoPoint(0, 0),
      locationName: "locationName",
      photo: "",
      // "https://images.unsplash.com/photo-1481349518771-20055b2a7b24?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1239&q=80",
      numParticipants: 1,
      creatorId: "user1Id",
      members: ["user1Id"]);
  static const OtherUser participant = OtherUser(
    id: "user1Id",
    name: "name",
    photo: "",
    interests: <String>[],
    description: "description",
  );
  static final Group group1 = Group(
    id: "group1Id",
    numParticipants: 1,
    name: "name",
    creatorId: "user1Id",
    caption: "caption",
    isPrivate: true,
    interests: <String>["food", "sport", "other"],
    photo: "",
    members: <String>[],
  );
  static final Group group2 = Group(
    id: "group2Id",
    numParticipants: 1,
    name: "name2",
    creatorId: "user1Id",
    caption: "caption",
    isPrivate: true,
    interests: <String>[],
    photo: "",
    // "https://images.unsplash.com/photo-1481349518771-20055b2a7b24?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1239&q=80",
    members: <String>[],
  );
  static final OurNotification notification1 = OurNotification(
      notificationId: "notification1Id",
      userIds: <String>["user1Id"],
      thingToOpenId: "event1Id",
      thingToNotifyName: "thingToNotifyName",
      sourceName: "sourceName",
      dateHour: "dateHour",
      timestamp: 2,
      chatMessage: "chatMessage",
      eventCategory: "eventCategory",
      public: false);
  static const UserData allUser1 = UserData(
    id: "allUser1Id",
    name: "allUser1",
    email: "email",
    description: "description",
    photo: "",
    interests: <String>[],
    notificationsGroupChat: true,
    notificationsEventChat: true,
    notificationsJoinGroup: true,
    notificationsInviteEvent: true,
    notificationsPublicEvent: true,
    notificationsPublicGroup: true,
    notificationsPush: true,
  );
}

class WidgetHomeUtils {
  static const currentUserData = UserData(
    id: "user1Id",
    name: "user1",
    email: "user1@mail.com",
    description: "user1 description",
    photo: "",
    interests: <String>["food", "party"],
    notificationsGroupChat: true,
    notificationsEventChat: true,
    notificationsJoinGroup: true,
    notificationsInviteEvent: true,
    notificationsPublicEvent: true,
    notificationsPublicGroup: true,
    notificationsPush: true,
  );
  static const group1 = {
    "num_participants": 0,
    "id": "group1Id",
    "name": "group1",
    "creator_id": "user1Id",
    "caption": "group1Caption",
    "private": false,
    "interests": <String>["food", "music"],
    "photo": "",
    "members": <String>["user1Id", "user3Id"],
  };
  static const group2 = {
    "num_participants": 0,
    "id": "group2Id",
    "name": "group2",
    "creator_id": "user2Id",
    "caption": "group2Caption",
    "private": false,
    "interests": <String>["food", "party"],
    "photo": "",
    "members": <String>["user2Id"],
  };
  static const user1 = {
    "name": "user1",
    "email": "user1@mail.com",
    "description": "user1 description",
    "photo": "",
    "interests": <String>["food", "party"],
    "events": <String>["event1Id"],
    "groups": <String>["group1Id"],
    'notifications_group_chat': true,
    'notifications_event_chat': true,
    'notifications_join_group': true,
    'notifications_invite_event': true,
    'notifications_public_event': true,
    'notifications_public_group': true,
    'notifications_push': true,
  };
  static const user2 = {
    "name": "user2",
    "email": "user2@mail.com",
    "description": "user2 description",
    "photo": "",
    "interests": <String>["food", "sport"],
    "events": <String>["event2Id"],
    "groups": <String>["group2Id"],
    'notifications_group_chat': true,
    'notifications_event_chat': true,
    'notifications_join_group': true,
    'notifications_invite_event': true,
    'notifications_public_event': true,
    'notifications_public_group': true,
    'notifications_push': true,
  };
  static const user3 = {
    "name": "user3",
    "email": "user3@mail.com",
    "description": "user3 description",
    "photo": "",
    "interests": <String>["food", "sport"],
    "events": <String>["event1Id"],
    "groups": <String>["group1Id"],
    'notifications_group_chat': true,
    'notifications_event_chat': true,
    'notifications_join_group': true,
    'notifications_invite_event': true,
    'notifications_public_event': true,
    'notifications_public_group': true,
    'notifications_push': true,
  };

  static final event1 = {
    "num_participants": 0,
    "id": "event1Id",
    "name": "event1",
    "creator_id": "user1Id",
    "description": "event1Caption",
    "private": false,
    "category": "sport",
    "photo": "",
    "date": Timestamp.fromDate(DateTime(2060, 10, 30, 18, 30)),
    "location": const GeoPoint(0, 0),
    "locationName": "test location name",
    "members": <String>["user1Id", "user3Id"],
  };
  static final event2 = {
    "num_participants": 0,
    "id": "event2Id",
    "name": "event2",
    "creator_id": "user2Id",
    "description": "event2Caption",
    "private": false,
    "category": "food",
    "photo": "",
    "date": Timestamp.fromDate(DateTime(2060, 10, 30, 18, 30)),
    "location": const GeoPoint(0, 0),
    "locationName": "test location name",
    "members": <String>["user2Id"],
  };
  static final messageEvent1 = {
    "date_hour": "2022-05-11 16:41", //String
    "sender_id": "user1Id",
    "sender_nickname": "user1",
    "sender_photo": "",
    "text": "message from user1",
    "time_stamp": 1683816106606, //number
    "type": 0,
  };
  static final secondMessageEvent1 = {
    "date_hour": "2023-05-04 19:36", //String
    "sender_id": "user2Id",
    "sender_nickname": "user2",
    "sender_photo": "",
    "text": "message from user2",
    "time_stamp": 1683221817133, //number
    "type": 0,
  };
  static final messageGroup1 = {
    "date_hour": "2023-05-11 16:41", //String
    "sender_id": "user1Id",
    "sender_nickname": "user1",
    "sender_photo": "",
    "text": "message from user1",
    "time_stamp": 1683816106606, //number
    "type": 0,
  };
  static final messageGroup2 = {
    "date_hour": "2023-05-04 19:36", //String
    "sender_id": "user2Id",
    "sender_nickname": "user2",
    "sender_photo": "",
    "text": "message from user2",
    "time_stamp": 1683221817133, //number
    "type": 0,
  };
  static Future<FakeFirebaseFirestore> getFakeFirestore() async {
    final FakeFirebaseFirestore fakeFirebaseFirestore = FakeFirebaseFirestore();
    await fakeFirebaseFirestore.collection("users").doc("user1Id").set(user1);
    await fakeFirebaseFirestore.collection("users").doc("user2Id").set(user2);
    await fakeFirebaseFirestore.collection("users").doc("user3Id").set(user3);
    await fakeFirebaseFirestore
        .collection("groups")
        .doc("group1Id")
        .set(group1);
    await fakeFirebaseFirestore
        .collection("groups")
        .doc("group2Id")
        .set(group2);
    await fakeFirebaseFirestore
        .collection("events")
        .doc("event1Id")
        .set(event1);
    await fakeFirebaseFirestore
        .collection("events")
        .doc("event2Id")
        .set(event2);
    await fakeFirebaseFirestore
        .collection("events")
        .doc("event1Id")
        .collection("chat")
        .doc()
        .set(messageEvent1);
    await fakeFirebaseFirestore
        .collection("events")
        .doc("event1Id")
        .collection("chat")
        .doc()
        .set(secondMessageEvent1);
    await fakeFirebaseFirestore
        .collection("groups")
        .doc("group1Id")
        .collection("chat")
        .doc()
        .set(messageGroup1);
    await fakeFirebaseFirestore
        .collection("groups")
        .doc("group1Id")
        .collection("chat")
        .doc()
        .set(messageGroup2);
    return fakeFirebaseFirestore;
  }
}
