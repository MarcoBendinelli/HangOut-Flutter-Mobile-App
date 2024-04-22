import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class EventsRepositoryUtils {
  static const UserData marco = UserData(
      id: "matteoId",
      name: "matteo",
      email: "matteo@mail.com",
      description: "matteo description",
      photo: "url to matteo photo",
      interests: ["food", "party"],
      notificationsEventChat: true,
      notificationsPush: true,
      notificationsGroupChat: true,
      notificationsInviteEvent: true,
      notificationsJoinGroup: true,
      notificationsPublicEvent: true,
      notificationsPublicGroup: true);
  static const UserData matteo = UserData(
      id: "marcoId",
      name: "marco",
      email: "marco@mail.com",
      description: "marco description",
      photo: "",
      interests: ["food", "sport"],
      notificationsEventChat: true,
      notificationsPush: true,
      notificationsGroupChat: true,
      notificationsInviteEvent: true,
      notificationsJoinGroup: true,
      notificationsPublicEvent: true,
      notificationsPublicGroup: true);
  static const UserData andrea = UserData(
      id: "andreaId",
      name: "andrea",
      email: "andrea@mail.com",
      description: "andrea description",
      photo: "",
      interests: ["study", "nature"],
      notificationsEventChat: true,
      notificationsPush: true,
      notificationsGroupChat: true,
      notificationsInviteEvent: true,
      notificationsJoinGroup: true,
      notificationsPublicEvent: true,
      notificationsPublicGroup: true);
  static final Event foodEvent = Event(
    category: "food",
    date: Timestamp.fromDate(DateTime.utc(2060, 7, 8, 16)),
    private: false,
    id: "foodEventId",
    name: "foodEvent",
    description: "foodEvent description",
    location: const GeoPoint(0, 0),
    locationName: "foodEvent location",
    photo: "",
    numParticipants: 1,
    creatorId: matteo.id,
  );
  static final Event musicEvent = Event(
    category: "music",
    date: Timestamp.fromDate(DateTime.utc(2060, 5, 8, 16)),
    private: false,
    id: "musicEventId",
    name: "musicEvent",
    description: "musicEvent description",
    location: const GeoPoint(30, 30),
    locationName: "musicEvent location",
    photo: "",
    numParticipants: 1,
    creatorId: matteo.id,
  );
  static final Event sportEvent = Event(
    category: "sport",
    date: Timestamp.fromDate(DateTime.utc(2060, 6, 8, 16)),
    private: false,
    id: "sportEventId",
    name: "sportEvent",
    description: "sportEvent description",
    location: const GeoPoint(4, 4),
    locationName: "sportEvent location",
    photo: "",
    numParticipants: 1,
    creatorId: marco.id,
  );
}

class RepositoryUtils {
  static const groupX = {
    "num_participants": 1,
    "id": "groupXId",
    "name": "groupX",
    "creator_id": "userXId",
    "caption": "groupXCaption",
    "private": false,
    "interests": <String>[],
    "photo": "",
    "members": <String>["userXId"],
  };
  static final eventX = {
    "num_participants": 1,
    "id": "eventXId",
    "name": "eventX",
    "creator_id": "userXId",
    "description": "eventXCaption",
    "private": false,
    "category": "food",
    "photo": "",
    "date": Timestamp.fromDate(DateTime(2060, 10, 30, 18, 30)),
    "location": const GeoPoint(0, 0),
    "locationName": "test location name",
    "members": <String>["userXId"],
  };
  static const group1 = {
    "num_participants": 0,
    "id": "group1Id",
    "name": "group1",
    "creator_id": "user1Id",
    "caption": "group1Caption",
    "private": false,
    "interests": <String>["food", "music"],
    "photo": "",
    "members": <String>[],
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
    "members": <String>[],
  };
  static const userX = {
    "name": "userXId",
    "email": "user1@mail.com",
    "description": "user1 description",
    "photo": "",
    "interests": <String>["food", "party"],
    "events": <String>["eventXId"],
    "groups": <String>["groupXId"],
    'notifications_group_chat': true,
    'notifications_event_chat': true,
    'notifications_join_group': true,
    'notifications_invite_event': true,
    'notifications_public_event': true,
    'notifications_public_group': true,
    'notifications_push': true,
  };
  static const user1 = {
    "name": "user1",
    "email": "user1@mail.com",
    "description": "user1 description",
    "photo": "",
    "interests": <String>["food", "party"],
    "events": <String>[],
    "groups": <String>[],
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
    "events": <String>[],
    "groups": <String>[],
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
    "category": "food",
    "photo": "",
    "date": Timestamp.fromDate(DateTime(2060, 10, 30, 18, 30)),
    "location": const GeoPoint(0, 0),
    "locationName": "test location name",
    "members": <String>[],
  };
  static final event2 = {
    "num_participants": 0,
    "id": "event2Id",
    "name": "event2",
    "creator_id": "user1Id",
    "description": "event2Caption",
    "private": false,
    "category": "food",
    "photo": "",
    "date": Timestamp.fromDate(DateTime(2060, 10, 30, 18, 30)),
    "location": const GeoPoint(0, 0),
    "locationName": "test location name",
    "members": <String>[],
  };

  static OurNotification notification1 = OurNotification(
      public: false,
      notificationId: 'id',
      userIds: <String>['id'],
      thingToOpenId: 'thingToOpenId',
      thingToNotifyName: 'thingToNotifyName',
      sourceName: 'sourceName',
      dateHour: 'dateHour',
      timestamp: 123,
      chatMessage: 'chatMessage',
      eventCategory: 'eventCategory');

  static OurNotification notificationSameIdOf1 = OurNotification(
      public: false,
      notificationId: 'id',
      userIds: <String>['id'],
      thingToOpenId: 'thingToOpenId',
      thingToNotifyName: 'thingToNotifyName',
      sourceName: 'sourceName',
      dateHour: 'dateHour',
      timestamp: 123,
      chatMessage: 'chatMessage2',
      eventCategory: 'eventCategory');

  static OurNotification notification2Users = OurNotification(
      public: false,
      notificationId: 'id',
      userIds: <String>['id1', 'id2'],
      thingToOpenId: 'thingToOpenId',
      thingToNotifyName: 'thingToNotifyName',
      sourceName: 'sourceName',
      dateHour: 'dateHour',
      timestamp: 123,
      chatMessage: '',
      eventCategory: '');

  static const OtherUser otherUser1 = OtherUser(
    id: "user1Id",
    name: "user1",
    photo: "",
    interests: <String>[],
    description: "description",
  );
  static const OtherUser otherUser2 = OtherUser(
    id: "user2Id",
    name: "user2",
    photo: "",
    interests: <String>[],
    description: "description",
  );

  Future<FakeFirebaseFirestore> getFakeFirestore() async {
    final FakeFirebaseFirestore fakeFirebaseFirestore = FakeFirebaseFirestore();
    await fakeFirebaseFirestore.collection("users").doc("user1Id").set(user1);
    await fakeFirebaseFirestore.collection("users").doc("user2Id").set(user2);
    await fakeFirebaseFirestore.collection("users").doc("userXId").set(userX);
    await fakeFirebaseFirestore
        .collection("groups")
        .doc("groupXId")
        .set(groupX);
    await fakeFirebaseFirestore
        .collection("events")
        .doc("eventXId")
        .set(eventX);
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
    return fakeFirebaseFirestore;
  }
}
