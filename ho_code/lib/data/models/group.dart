// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';

/// Group model
class Group {
  final String name;
  final String id;
  final String creatorId;
  final String caption;
  final int? numParticipants;
  final bool isPrivate;
  final List<String> interests;
  final String? photo;

  //these are the members ids loaded from firestore
  final List<String>? members;

  Group({
    this.numParticipants,
    required this.id,
    required this.name,
    required this.creatorId,
    required this.caption,
    required this.isPrivate,
    required this.interests,
    this.photo,
    this.members,
  });

  factory Group.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Group(
      id: snapshot.id,
      name: data?['name'],
      creatorId: data?['creator_id'],
      caption: data?['caption'],
      numParticipants: data?['num_participants'],
      isPrivate: data?['private'],
      interests: List.from(data?['interests']),
      photo: data?['photo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) "name": name,
      if (creatorId != null) "creator_id": creatorId,
      if (caption != null) "caption": caption,
      if (numParticipants != null) "num_participants": numParticipants,
      if (isPrivate != null) "private": isPrivate,
      if (interests != null) "interests": interests,
      if (photo != null) "photo": photo,
    };
  }

  static Group fromSnapshot(DocumentSnapshot snap) {
    Group group = Group(
      id: snap.id,
      name: snap['name'],
      creatorId: snap['creator_id'],
      caption: snap['caption'],
      numParticipants: snap['num_participants'],
      isPrivate: snap['private'],
      interests: List.from(snap['interests']),
      photo: snap['photo'],
      members: List.from(snap['members']),
    );
    return group;
  }
}
