part of 'groups_bloc.dart';

abstract class GroupsState extends Equatable {
  const GroupsState();

  @override
  List<Object> get props => [];
}

class GroupsLoading extends GroupsState {}

class GroupsError extends GroupsState {}

class GroupsLoaded extends GroupsState {
  final List<Group> groups;

  const GroupsLoaded({this.groups = const <Group>[]});

  @override
  List<Object> get props => [groups];
}
