// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Group model
class OtherUser extends Equatable {
  final String id;
  final String name;
  final String photo;
  final String description;
  final List<String> interests;

  const OtherUser(
      {required this.id,
      required this.name,
      required this.photo,
      required this.interests,
      required this.description});
  Map<String, dynamic> toMap() {
    return {
      if (id != null) "id": id,
      if (name != null) "name": name,
      if (photo != null) "photo": photo,
      if (interests != null) "interests": interests,
      if (description != null) "description": description,
    };
  }

  factory OtherUser.fromMap(Map data) {
    return OtherUser(
      id: data['id'],
      name: data['name'],
      photo: data['photo'],
      description: data['description'],
      interests: data['interests'],
    );
  }

  static OtherUser fromSnapshot(DocumentSnapshot snap) {
    OtherUser event = OtherUser(
      id: snap.id,
      name: snap['name'],
      photo: snap['photo'],
      description: snap['description'],
      interests: List.from(snap['interests']),
    );
    return event;
  }

  @override
  List<Object?> get props => [id, name, photo, description, interests];
}
