part of 'members_bloc.dart';

abstract class MembersState extends Equatable {
  const MembersState();

  @override
  List<Object> get props => [];
}

class MembersInit extends MembersState {}

class MembersLoading extends MembersState {}

class MembersError extends MembersState {}

class MembersLoaded extends MembersState {
  final List<OtherUser> members;

  const MembersLoaded({required this.members});

  @override
  List<Object> get props => [members];
}

class GroupsLoaded extends MembersState {
  final List<Group> groups;

  const GroupsLoaded({required this.groups});

  @override
  List<Object> get props => [groups];
}
