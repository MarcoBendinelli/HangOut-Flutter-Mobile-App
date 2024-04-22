import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/models/other_user.dart';

void main() {
  group("OtherUser tests", () {
    test("test can be converted to map and from map", () {
      OtherUser user1 = const OtherUser(
          id: "userId",
          name: "userName",
          photo: "userPhoto",
          interests: ["food"],
          description: "description");
      dynamic map = user1.toMap();
      OtherUser user2 = OtherUser.fromMap(map);
      expect(user2, user1);
    });
    test("test can be converted from snapshot", () async {
      FirebaseFirestore firebaseFirestore = FakeFirebaseFirestore();
      firebaseFirestore.collection("users").doc("userId").set(const {
        "id": "userId",
        "email": "email@email.it",
        "name": "userName",
        "description": "description",
        "interests": ["food"],
        "photo": "userPhoto"
      });
      final snapshot =
          await firebaseFirestore.collection("users").doc("userId").get();
      final OtherUser userFromSnap = OtherUser.fromSnapshot(snapshot);
      OtherUser user1 = const OtherUser(
          id: "userId",
          name: "userName",
          photo: "userPhoto",
          description: "description",
          interests: ["food"]);
      expect(userFromSnap, user1);
      expect(userFromSnap.id, "userId");
      expect(userFromSnap.name, "userName");
      expect(userFromSnap.photo, "userPhoto");
      expect(userFromSnap.description, "description");
      expect(userFromSnap.interests, ["food"]);
    });
  });
}
