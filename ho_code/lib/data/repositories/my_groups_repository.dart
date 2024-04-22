import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MyGroupsRepository {
  final FirebaseFirestore _db;
  final Reference referenceDirImages;

  MyGroupsRepository(
      {FirebaseFirestore? firebaseFirestore, FirebaseStorage? firebaseStorage})
      : _db = firebaseFirestore ?? FirebaseFirestore.instance,
        referenceDirImages = firebaseStorage?.ref().child("groups") ??
            FirebaseStorage.instance.ref().child("groups");

  /// To save a new group in the Firebase database
  Future<String> saveNewGroup(
      {required Group group,
      required OtherUser creator,
      required XFile? imageFile,
      required List<OtherUser> members}) async {
    final groupRef = _db
        .collection("groups")
        .withConverter(
            fromFirestore: Group.fromFirestore,
            toFirestore: (Group group, options) => group.toMap())
        .doc();

    /// Save the new group in the collection Groups
    await groupRef.set(group);
    await groupRef.update({'id': groupRef.id});

    ///If Group has image update photo field value with the loaded photo
    if (imageFile != null) {
      String? imageURL = await uploadImage(imageFile, groupRef.id);

      /// Update the imageURL field of the group in Firestore
      await groupRef.update({'photo': imageURL});
    }

    /// Save the id of the new group to the user groups Array
    await _db.collection("users").doc(creator.id).update({
      "groups": FieldValue.arrayUnion([groupRef.id]),
    });

    /// Save the id of the user as member
    await _db.collection("groups").doc(groupRef.id).update({
      "members": FieldValue.arrayUnion([creator.id]),
    });

    /// Save the added users by the creator in the members of the group +
    /// Save the id of the new group in the my_groups collection of the users
    for (OtherUser member in members) {
      await _db.collection("users").doc(member.id).update({
        "groups": FieldValue.arrayUnion([groupRef.id]),
      });
      await _db.collection("groups").doc(groupRef.id).update({
        "members": FieldValue.arrayUnion([member.id]),
      });
    }

    return groupRef.id;
  }

  Future<void> deleteGroupWithId({required String groupId}) async {
    List<String> ids = [];

    await _db
        .collection('users')
        .where("groups", arrayContains: groupId)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          ids.add(docSnapshot.id);
        }
      },
    );

    for (final idUser in ids) {
      /// Remove the id of the new group from the user groups Array
      await _db.collection("users").doc(idUser).update({
        "groups": FieldValue.arrayRemove([groupId]),
      });
    }

    /// Delete all the messages inside the chat

    var collection = _db.collection("groups").doc(groupId).collection("chat");
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }

    try {
      await referenceDirImages.child(groupId).delete();
    } on Exception catch (_) {}

    /// Finally delete the group collection
    await _db.collection("groups").doc(groupId).delete();

    /// Delete the notification inherent to this group
    try {
      var ref = _db
          .collection('notifications')
          .where("thing_to_open_id", isEqualTo: groupId);
      ref.get().then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    } on Exception catch (_) {}
  }

  Future<String?> uploadImage(XFile file, String id) async {
    String imageURL;

    Reference imageRef = referenceDirImages.child(id);

    try {
      //store file in reference
      await imageRef.putFile(File(file.path));
      imageURL = await imageRef.getDownloadURL();
      return imageURL;
    } on Exception {
      return null;
    }
  }

  Stream<List<OtherUser>> getParticipantsToGroup(String groupId) {
    return _db
        .collection('users')
        .where("groups", arrayContains: groupId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OtherUser.fromSnapshot(doc)).toList();
    });
  }

  Future<Stream<List<Group>>> getGroupsOfUser(String userId) async {
    return _db
        .collection('groups')
        .where("members", arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Group.fromSnapshot(doc)).toList();
    });
  }

  Future<Stream<List<Group>>> getNonParticipatingGroupOfUser(
      String userId, List<String> categories) async {
    List<String> myGroupsIds = [];
    final docRef = _db.collection("users").doc(userId);

    //Get all Ids of events the user is participating to (1 read)
    await docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        myGroupsIds = List.from(data["groups"]);
      },
      onError: (e) => debugPrint("Error getting document: $e"),
    );

    /// Return the groups where the user is NOT inside
    if (categories.isEmpty) {
      //In filter requires a non empty iterable so i add a fake category
      categories = ["a"];
    }
    return _db
        .collection('groups')
        .where("private", isEqualTo: false)
        // .where("interests", whereIn: categories)
        // .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Group.fromSnapshot(doc))
          .toList()
          .where((group) => !myGroupsIds.any((id) => id == group.id))
          .where((group) {
        bool containsCategory = false;
        for (var category in categories) {
          if (group.interests.contains(category)) {
            containsCategory = true;
            break;
          }
        }
        return containsCategory;
      }).toList();
    });
  }

  Future<void> joinGroup(
      {required OtherUser user, required String groupId}) async {
    /// Save the id of the new event to the user events Array
    await _db.collection("users").doc(user.id).update({
      "groups": FieldValue.arrayUnion([groupId]),
    });

    /// Save the id of the user as member
    await _db.collection("groups").doc(groupId).update({
      "members": FieldValue.arrayUnion([user.id]),
      "num_participants": FieldValue.increment(1)
    });
  }

  Future<void> leaveGroup(
      {required String groupId, required String userId}) async {
    /// Remove the id of the new event from the user events Array
    await _db.collection("users").doc(userId).update({
      "groups": FieldValue.arrayRemove([groupId]),
    });

    /// remove the id of the user from event members
    await _db.collection("groups").doc(groupId).update({
      "members": FieldValue.arrayRemove([userId]),
      "num_participants": FieldValue.increment(-1)
    });

    try {
      String notificationId = await _db
          .collection("notifications")
          .where("thing_to_open_id", isEqualTo: groupId)
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

      /// The notification is seen by the user so I can remove him/her
      await _db.collection("notifications").doc(notificationId).update({
        "user_ids": FieldValue.arrayRemove([userId]),
      });

      /// Get the notification object to see if the array of user is empty
      final ref =
          _db.collection("notifications").doc(notificationId).withConverter(
                fromFirestore: OurNotification.fromFirestore,
                toFirestore: (OurNotification notification, _) =>
                    notification.toMap(),
              );

      final docSnap = await ref.get();
      OurNotification notification = docSnap.data()!;

      if (notification.userIds.isEmpty) {
        /// All the users have seen the notification, thus, I can remove it
        await _db.collection("notifications").doc(notificationId).delete();
      }
    } catch (_) {
      debugPrint("Leave group: notification");
    }
  }

  /// To get the event with id equal to eventId
  Future<Stream<Group>> getGroupWithId(String groupId) async {
    return _db
        .collection('groups')
        .where("id", isEqualTo: groupId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Group.fromSnapshot(doc))
            .toList()
            .firstWhere((group) => group.id == groupId));
  }

  /// To get the groups in common between 2 users
  Future<Stream<List<Group>>> getCommonGroups(
      String firstId, String secondId) async {
    List<String> firstGroupsIds = [];
    List<String> secondGroupsIds = [];

    /// Get the list of ids of the groups where the first user is inside
    await _db
        .collection("groups")
        .where("members", arrayContains: firstId)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          firstGroupsIds.add(docSnapshot.id);
        }
      },
      onError: (e) => debugPrint("Error completing: $e"),
    );

    /// Get the list of ids of the groups where the second user is inside
    await _db
        .collection("groups")
        .where("members", arrayContains: secondId)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          secondGroupsIds.add(docSnapshot.id);
        }
      },
      onError: (e) => debugPrint("Error completing: $e"),
    );

    final intersection =
        firstGroupsIds.toSet().intersection(secondGroupsIds.toSet()).toList();

    /// Return the groups where the user is inside
    return _db.collection('groups').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Group.fromSnapshot(doc))
          .toList()
          .where((group) => intersection.any((id) => id == group.id))
          .toList();
    });
  }

  Future<void> modifyGroup(
      {required Group group,
      required XFile? imageFile,
      required List<OtherUser> newMembers,
      required String creatorId}) async {
    List<String> oldIdsInGroup = [];

    final groupRef = _db.collection("groups").doc(group.id);

    await _db
        .collection('users')
        .where("groups", arrayContains: group.id)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          oldIdsInGroup.add(docSnapshot.id);
        }
      },
      onError: (e) => debugPrint("Error completing: $e"),
    );

    /// Modify the group
    await groupRef.update(group.toMap());

    /// Check if image has been changed and update it in case
    if (imageFile != null) {
      String? imageURL = await uploadImage(imageFile, group.id);

      /// Update the imageURL field of the group in Firestore
      await _db.collection("groups").doc(group.id).update({'photo': imageURL});
    }

    /// Update the added or removed users by the creator in the members of the group +
    /// Save or Remove the id of the new group in the my_groups collection of the users
    for (String oldIdMember in oldIdsInGroup) {
      if (newMembers.map((e) => e.id).contains(oldIdMember)) {
        // Do nothing, the user didn't remove the old member
        newMembers.removeWhere((e) => e.id == oldIdMember);
      } else if (oldIdMember != creatorId) {
        // The user removes an old member
        await leaveGroup(groupId: group.id, userId: oldIdMember);
      }
    }

    // The user added new members in the group
    for (OtherUser member in newMembers) {
      await joinGroup(user: member, groupId: group.id);
    }
  }
}
