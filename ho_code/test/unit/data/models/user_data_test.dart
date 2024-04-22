import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/models/user_data.dart';

void main() {
  group("UserData tests", () {
    test("test can be converted to map and from map", () {
      UserData user1 = const UserData(
          id: "userId",
          name: "name",
          email: "email",
          description: "description",
          photo: "photo",
          interests: ["food"],
          notificationsPush: true,
          notificationsGroupChat: true,
          notificationsEventChat: true,
          notificationsJoinGroup: true,
          notificationsInviteEvent: true,
          notificationsPublicEvent: true,
          notificationsPublicGroup: true);
      dynamic map = user1.toMap();
      UserData user2 = UserData.fromMap(map);
      expect(user2, user1);
    });
    test("test can be converted from snapshot", () async {
      FirebaseFirestore firebaseFirestore = FakeFirebaseFirestore();
      firebaseFirestore.collection("users").doc("userId").set(const {
        "id": "userId",
        "name": "name",
        "email": "email",
        "description": "description",
        "photo": "photo",
        "interests": ["food"],
        "notifications_push": true,
        "notifications_group_chat": true,
        "notifications_event_chat": true,
        "notifications_join_group": true,
        "notifications_invite_event": true,
        "notifications_public_event": true,
        "notifications_public_group": true
      });
      final snapshot =
          await firebaseFirestore.collection("users").doc("userId").get();
      final UserData userFromSnap = UserData.fromSnapshot(snapshot);
      UserData user1 = const UserData(
          id: "userId",
          name: "name",
          email: "email",
          description: "description",
          photo: "photo",
          interests: ["food"],
          notificationsPush: true,
          notificationsGroupChat: true,
          notificationsEventChat: true,
          notificationsJoinGroup: true,
          notificationsInviteEvent: true,
          notificationsPublicEvent: true,
          notificationsPublicGroup: true);
      expect(userFromSnap, user1);
    });
  });
}
