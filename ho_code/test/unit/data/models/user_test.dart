import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/models/user.dart';

void main() {
  group("user tests", () {
    test("test that user with no id is empty", () {
      const User user = User(id: "");
      expect(true, user.isEmpty);
      expect(false, user.isNotEmpty);
    });
    test("test that user with id not empty", () {
      const User user = User(id: "id");
      expect(false, user.isEmpty);
      expect(true, user.isNotEmpty);
    });
    test("test that user can be created from map", () {
      User user = User.fromMap(const {
        "id": "userId",
        "email": "email@email.it",
        "name": "userName",
        "photo": "userPhoto"
      });
      expect(false, user.isEmpty);
      expect(true, user.isNotEmpty);
      expect(user.id, "userId");
      expect(user.email, "email@email.it");
      expect(user.name, "userName");
      expect(user.photo, "userPhoto");
    });
    test("test that user can be converted to map", () {
      User user1 = const User(
          id: "userId",
          name: "userName",
          photo: "userPhoto",
          email: "email@email.it");
      dynamic map = user1.toMap();
      User user2 = User.fromMap(map);
      expect(user2, user1);
      expect(false, user2.isEmpty);
      expect(true, user2.isNotEmpty);
      expect(user2.id, "userId");
      expect(user2.email, "email@email.it");
      expect(user2.name, "userName");
      expect(user2.photo, "userPhoto");
    });
    test("test that user can be converted from snapShot", () async {
      FirebaseFirestore firebaseFirestore = FakeFirebaseFirestore();
      firebaseFirestore.collection("users").doc("userId").set(const {
        "id": "userId",
        "email": "email@email.it",
        "name": "userName",
        "photo": "userPhoto"
      });
      final snapshot =
          await firebaseFirestore.collection("users").doc("userId").get();
      final User userFromSnap = User.fromFirestore(snapshot, null);
      User user1 = const User(
          id: "userId",
          name: "userName",
          photo: "userPhoto",
          email: "email@email.it");
      expect(userFromSnap, user1);
      expect(false, userFromSnap.isEmpty);
      expect(true, userFromSnap.isNotEmpty);
      expect(userFromSnap.id, "userId");
      expect(userFromSnap.email, "email@email.it");
      expect(userFromSnap.name, "userName");
      expect(userFromSnap.photo, "userPhoto");
    });
  });
}
