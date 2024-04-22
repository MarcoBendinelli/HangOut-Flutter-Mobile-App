part of 'groups_bloc.dart';

abstract class GroupsEvent extends Equatable {
  const GroupsEvent();
}

class LoadGroups extends GroupsEvent {
  final String userId;

  const LoadGroups({required this.userId});

  @override
  List<Object> get props => [userId];
}
