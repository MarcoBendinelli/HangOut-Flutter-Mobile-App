// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Event model
class Event {
  /// The Event's id
  final String id;

  ///The Event's name
  final String name;

  ///The event category
  final String category;

  /// The number of participants (in firestore num_participants and do not change)
  final int? numParticipants;

  /// Url for the group's image
  final String? photo;

  ///event DateTime
  final Timestamp date;

  ///Event private setting
  final bool private;

  ///Event description
  final String description;

  ///Event creator
  final String? creatorId;

  ///Event location
  final GeoPoint location;

  ///Event location name
  final String locationName;

  final List<String>? members;

  const Event({
    required this.category,
    required this.date,
    this.photo,
    this.numParticipants,
    required this.private,
    required this.id,
    required this.name,
    this.creatorId,
    required this.description,
    required this.location,
    required this.locationName,
    this.members,
  });

  factory Event.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Event(
      id: snapshot.id,
      name: data?['name'],
      creatorId: data?['creator_id'],
      description: data?['description'],
      category: data?['category'],
      private: data?['private'],
      numParticipants: data?['num_participants'],
      date: data?['date'],
      photo: data?['photo'],
      location: data?['location'],
      locationName: data?['locationName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) "name": name,
      if (creatorId != null) "creator_id": creatorId,
      if (description != null) "description": description,
      if (category != null) "category": category,
      if (private != null) "private": private,
      if (numParticipants != null) "num_participants": numParticipants,
      if (date != null) "date": date,
      if (photo != null) "photo": photo,
      if (location != null) "location": location,
      if (locationName != null) "locationName": locationName,
    };
  }

  static Event fromSnapshot(DocumentSnapshot snap) {
    Event event = Event(
      id: snap.id,
      name: snap['name'],
      creatorId: snap['creator_id'],
      description: snap['description'],
      category: snap['category'],
      private: snap['private'],
      numParticipants: snap['num_participants'],
      date: snap['date'],
      photo: snap['photo'],
      location: snap['location'],
      locationName: snap['locationName'],
      members: List.from(snap['members']),
    );
    return event;
  }

  String getDayName() {
    final DateFormat format = DateFormat('EEEE');
    return format.format(date.toDate());
  }

  String getDay() {
    return date.toDate().day.toString();
  }

  String getMonth() {
    final format = DateFormat('MMM');
    return format.format(date.toDate());
  }

  String getYear() {
    return date.toDate().year.toString();
  }

  String getHour() {
    return DateFormat("h:mma").format(date.toDate());
  }
}
