part of 'members_bloc.dart';

abstract class MembersEvent extends Equatable {
  const MembersEvent();

  @override
  List<Object> get props => [];
}

class GoInInitState extends MembersEvent {}

class LoadMembersInEvent extends MembersEvent {
  final String eventId;

  const LoadMembersInEvent({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

class LoadMembersInGroup extends MembersEvent {
  final String groupId;
  final String currentUserId;

  const LoadMembersInGroup(
      {required this.currentUserId, required this.groupId});

  @override
  List<Object> get props => [groupId, currentUserId];
}

class LoadGroupForUser extends MembersEvent {
  final String userId;

  const LoadGroupForUser({required this.userId});

  @override
  List<Object> get props => [userId];
}

class LoadSelectedUsers extends MembersEvent {
  final List<String> idUsers;
  final String currentUserId;

  const LoadSelectedUsers({required this.idUsers, required this.currentUserId});

  @override
  List<Object> get props => [idUsers, currentUserId];
}

class LoadSelectedUsersAndGroupMembers extends MembersEvent {
  final String groupId;
  final String currentUserId;

  const LoadSelectedUsersAndGroupMembers(
      {required this.groupId, required this.currentUserId});

  @override
  List<Object> get props => [groupId, currentUserId];
}
