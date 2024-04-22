import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

class UserRepository {
  final FirebaseFirestore _db;
  final Reference referenceDirImages;

  UserRepository(
      {FirebaseFirestore? firebaseFirestore, FirebaseStorage? firebaseStorage})
      : _db = firebaseFirestore ?? FirebaseFirestore.instance,
        referenceDirImages = firebaseStorage?.ref().child("users") ??
            FirebaseStorage.instance.ref().child("users");

  Future<UserData> getUserData(String? id) async {
    final docRef = _db.collection('users').doc(id);
    final snapshot = await docRef.get();
    final userData = UserData.fromSnapshot(snapshot);
    return userData;
  }

  Future<void> modifyUser(
      {required UserData user,
      required XFile? profileImage,
      required isNicknameModified}) async {
    final userRef = _db.collection("users").doc(user.id);

    /// Update the user
    await userRef.update(user.toMap());

    if (isNicknameModified || profileImage != null) {
      /// Check if image has been changed and update it in case
      if (profileImage != null) {
        String? imageURL = await uploadImage(profileImage, user.id);

        /// Update the imageURL field of the group in Firestore
        await _db.collection("users").doc(user.id).update({'photo': imageURL});

        /// Update the photo in the chats of the user
        await renameInfoInChat(
            id: user.id, fieldToUpdate: "sender_photo", theUpdate: imageURL);
      }

      /// Update the nickname in the chats of the user if necessary
      if (isNicknameModified) {
        await renameInfoInChat(
            id: user.id,
            fieldToUpdate: "sender_nickname",
            theUpdate: user.name);
      }
    }
  }

  Future<void> renameInfoInChat(
      {required String id,
      required String fieldToUpdate,
      required String? theUpdate}) async {
    _db
        .collectionGroup('chat')
        .where('sender_id', isEqualTo: id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var documentSnapshot in querySnapshot.docs) {
        documentSnapshot.reference.update({fieldToUpdate: theUpdate});
      }
    });
  }

  Stream<UserData> getUserDataStream(String? id) {
    return _db
        .collection("users")
        .doc(id)
        .snapshots()
        .map((event) => UserData.fromSnapshot(event));
  }

  /// It returns the all groups in the database
  Stream<List<UserData>> getAllUsers() {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserData.fromSnapshot(doc)).toList();
    });
  }

  /// It returns the users with the specified ids
  Stream<List<OtherUser>> getTheseUsers(List<String> selectedIdUsers) {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OtherUser.fromSnapshot(doc))
          .where((user) => selectedIdUsers.contains(user.id))
          .toList();
    });
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

  Future<List<String>> getInterestedUsersToNotify(
      {required List<String> newGroupEventInterests}) async {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OtherUser.fromSnapshot(doc))
          .where((user) {
            for (String interest in newGroupEventInterests) {
              if (user.interests.contains(interest)) {
                return true;
              }
            }
            return false;
          })
          .map((user) => user.id)
          .toList();
    }).first;
  }
}
