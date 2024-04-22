part of 'explore_bloc.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();
  
  @override
  List<Object> get props => [];
}

class ExploreEventsLoading extends ExploreState {}
class ExploreGroupsLoading extends ExploreState {}
class ExploreLoadingError extends ExploreState{}


class ExploreEventsLoaded extends ExploreState {
  final List<Event> events;
  const ExploreEventsLoaded({this.events = const <Event>[]});
  @override
  List<Object> get props => [events]; 
}

//Change EventCardModel with group one
class ExploreGroupsLoaded extends ExploreState {
  final List<Group> groups;
  const ExploreGroupsLoaded({this.groups = const <Group>[]});
  @override
  List<Object> get props => [groups]; 
}