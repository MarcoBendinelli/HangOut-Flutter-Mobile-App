// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Group model
class UserData extends Equatable {
  final String id;
  final String name;
  final String email;
  final String photo;
  final String description;
  final List<String> interests;
  final bool notificationsPush;
  final bool notificationsGroupChat;
  final bool notificationsEventChat;
  final bool notificationsJoinGroup;
  final bool notificationsInviteEvent;
  final bool notificationsPublicEvent;
  final bool notificationsPublicGroup;
  static const empty = UserData(
      id: "id",
      name: "",
      email: "",
      photo: "",
      description: "",
      interests: [],
      notificationsEventChat: true,
      notificationsPush: true,
      notificationsGroupChat: true,
      notificationsInviteEvent: true,
      notificationsJoinGroup: true,
      notificationsPublicEvent: true,
      notificationsPublicGroup: true);

  const UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.description,
    required this.photo,
    required this.interests,
    required this.notificationsPush,
    required this.notificationsGroupChat,
    required this.notificationsEventChat,
    required this.notificationsJoinGroup,
    required this.notificationsInviteEvent,
    required this.notificationsPublicEvent,
    required this.notificationsPublicGroup,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) "id": id,
      if (name != null) "name": name,
      if (email != null) "email": email,
      if (photo != null) "photo": photo,
      if (interests != null) "interests": interests,
      if (description != null) "description": description,
      if (notificationsPush != null) 'notificationsPush': notificationsPush,
      if (notificationsGroupChat != null)
        'notificationsGroupChat': notificationsGroupChat,
      if (notificationsEventChat != null)
        'notificationsEventChat': notificationsEventChat,
      if (notificationsJoinGroup != null)
        'notificationsJoinGroup': notificationsJoinGroup,
      if (notificationsInviteEvent != null)
        'notificationsInviteEvent': notificationsInviteEvent,
      if (notificationsPublicEvent != null)
        'notificationsPublicEvent': notificationsPublicEvent,
      if (notificationsPublicGroup != null)
        'notificationsPublicGroup': notificationsPublicGroup,
    };
  }

  factory UserData.fromMap(Map data) {
    return UserData(
        id: data['id'],
        name: data['name'],
        email: data['email'],
        description: data['description'],
        photo: data['photo'],
        interests: data['interests'],
        notificationsPush: data['notificationsPush'],
        notificationsGroupChat: data['notificationsGroupChat'],
        notificationsEventChat: data['notificationsEventChat'],
        notificationsJoinGroup: data['notificationsJoinGroup'],
        notificationsInviteEvent: data['notificationsInviteEvent'],
        notificationsPublicEvent: data['notificationsPublicEvent'],
        notificationsPublicGroup: data['notificationsPublicGroup']);
  }

  static UserData fromSnapshot(DocumentSnapshot snap) {
    UserData user = UserData(
      id: snap.id,
      name: snap['name'],
      email: snap['email'],
      photo: snap['photo'],
      interests: List.from(snap['interests']),
      description: snap['description'],
      notificationsEventChat: snap['notifications_event_chat'],
      notificationsPush: snap['notifications_push'],
      notificationsGroupChat: snap['notifications_group_chat'],
      notificationsInviteEvent: snap['notifications_invite_event'],
      notificationsJoinGroup: snap['notifications_join_group'],
      notificationsPublicEvent: snap['notifications_public_event'],
      notificationsPublicGroup: snap['notifications_public_group'],
    );
    return user;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        photo,
        email,
        description,
        interests,
        notificationsPush,
        notificationsGroupChat,
        notificationsEventChat,
        notificationsJoinGroup,
        notificationsInviteEvent,
        notificationsPublicEvent,
        notificationsPublicGroup
      ];
}
