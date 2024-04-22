import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:hang_out_app/data/models/event.dart';

import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:image_picker/image_picker.dart';

class MyEventsRepository {
  final FirebaseFirestore _db;
  final Reference referenceDirImages;

  MyEventsRepository(
      {FirebaseFirestore? firebaseFirestore, FirebaseStorage? firebaseStorage})
      : _db = firebaseFirestore ?? FirebaseFirestore.instance,
        referenceDirImages = firebaseStorage?.ref().child("events") ??
            FirebaseStorage.instance.ref().child("events");

  Stream<List<OtherUser>> getParticipantsToEvent(String eventId) {
    return _db
        .collection('users')
        .where("events", arrayContains: eventId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OtherUser.fromSnapshot(doc)).toList();
    });
  }

  Future<String> saveNewEvent(
      {required Event event,
      required UserData creator,
      XFile? imageFile}) async {
    final eventRef = _db
        .collection("events")
        .withConverter(
          fromFirestore: Event.fromFirestore,
          toFirestore: (Event event, options) => event.toMap(),
        )
        .doc();

    /// Save the new event in the collection Events
    await eventRef.set(event);
    await eventRef.update({'id': eventRef.id});

    ///If Event has image update photo field value with the loaded photo
    if (imageFile != null) {
      String imageURL = await uploadImage(imageFile, eventRef.id);

      /// Update the imageURL field of the event in Firestore
      await eventRef.update({'photo': imageURL});
    }

    /// Save the id of the new event to the user events Array
    await _db.collection("users").doc(creator.id).update({
      "events": FieldValue.arrayUnion([eventRef.id]),
    });

    /// Save the id of the user as member
    await _db.collection("events").doc(eventRef.id).update({
      "members": FieldValue.arrayUnion([creator.id]),
    });

    return eventRef.id;
  }

  /// To get the groups where the current User is inside
  Future<Stream<List<Event>>> getEventsOfUser(String userId) async {
    DateTime currentDeviceDateTime = DateTime.now();
    return _db
        .collection('events')
        .where('date', isGreaterThan: Timestamp.fromDate(currentDeviceDateTime))
        .where("members", arrayContains: userId)
        .orderBy("date")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromSnapshot(doc)).toList();
    });
  }

  Future<Stream<List<Event>>> getNonParticipatingEventsOfUser(
      String userId, List<String> categories) async {
    List<String> myEventsIds = [];
    final docRef = _db.collection("users").doc(userId);
    DateTime currentDeviceDateTime = DateTime.now();

    //Get all Ids of events the user is participating to (1 read)
    await docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        myEventsIds = List.from(data["events"]);
      },
      onError: (e) => debugPrint("Error getting document: $e"),
    );

    /// Return the groups where the user is NOT inside
    if (categories.isEmpty) {
      //In filter requires a non empty iterable so i add a fake category
      categories = ["a"];
    }
    return _db
        .collection('events')
        .where('date', isGreaterThan: Timestamp.fromDate(currentDeviceDateTime))
        .where("private", isEqualTo: false)
        // .where("id", whereNotIn: myEventsIds) //can't be done here unfortunatly
        .where("category", whereIn: categories)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Event.fromSnapshot(doc))
          .toList()
          .where((event) => !myEventsIds.any((id) => id == event.id))
          .toList();
    });
  }

  Future<String> uploadImage(XFile file, String id) async {
    String imageURL;

    Reference imageRef = referenceDirImages.child(id);

    try {
      //store file in reference
      await imageRef.putFile(File(file.path));
      imageURL = await imageRef.getDownloadURL();
      return imageURL;
    } on Exception {
      return "";
    }
  }

  Future<void> addEventToUser(
      {required UserData user, required String eventId}) async {
    /// Save the id of the new event to the user events Array
    await _db.collection("users").doc(user.id).update({
      "events": FieldValue.arrayUnion([eventId]),
    });

    /// Save the id of the user as member
    await _db.collection("events").doc(eventId).update({
      "members": FieldValue.arrayUnion([user.id]),
      "num_participants": FieldValue.increment(1)
    });
  }

  Future<void> removeEventfromUser(
      {required UserData user, required String eventId}) async {
    /// Remove the id of the new event from the user events Array
    await _db.collection("users").doc(user.id).update({
      "events": FieldValue.arrayRemove([eventId]),
    });

    /// remove the id of the user from event members
    await _db.collection("events").doc(eventId).update({
      "members": FieldValue.arrayRemove([user.id]),
      "num_participants": FieldValue.increment(-1)
    });
  }

  Future<void> modifyEvent({required Event event, XFile? imageFile}) async {
    /// modify the event
    await _db.collection("events").doc(event.id).update(event.toMap());

    ///check if image has been changed and update it in case
    if (imageFile != null) {
      String imageURL = await modifyImage(imageFile, event.id);

      /// Update the imageURL field of the event in Firestore
      await _db.collection("events").doc(event.id).update({'photo': imageURL});
    }
  }

  /// To get the event with id equal to eventId
  Future<Stream<Event>> getEventWithId(String eventId) async {
    return _db
        .collection('events')
        .where("id", isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromSnapshot(doc))
            .toList()
            .firstWhere((event) => event.id == eventId));
  }

  Future<String> modifyImage(XFile file, String id) async {
    String imageURL;

    Reference imageRef = referenceDirImages.child(id);

    try {
      //store file in reference
      await imageRef.putFile(File(file.path));
      imageURL = await imageRef.getDownloadURL();
      return imageURL;
    } on Exception {
      return "";
    }
  }

  Future<void> deleteSingleEvent({required String eventId}) async {
    List<String> ids = [];

    await _db
        .collection('users')
        .where("events", arrayContains: eventId)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          ids.add(docSnapshot.id);
        }
      },
    );

    for (final idUser in ids) {
      /// Remove the id of the new event from the user events Array
      await _db.collection("users").doc(idUser).update({
        "events": FieldValue.arrayRemove([eventId]),
      });
    }

    /// Delete all the messages inside the chat
    var collection = _db.collection("events").doc(eventId).collection("chat");
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }

    try {
      await referenceDirImages.child(eventId).delete();
    } on Exception catch (_) {}

    /// Finally delete the group collection
    await _db.collection("events").doc(eventId).delete();

    /// Delete the notification inherent to this event
    try {
      var ref = _db
          .collection('notifications')
          .where("thing_to_open_id", isEqualTo: eventId);
      ref.get().then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    } catch (_) {
      debugPrint("Delete event: notification");
    }
  }
}
