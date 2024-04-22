part of 'explore_bloc.dart';

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();
}

class LoadExploreEvents extends ExploreEvent {
  final String userId;
  final List<String>? categories;

  const LoadExploreEvents({required this.userId, this.categories});

  @override
  List<Object?> get props => [userId, categories];
}

class LoadExploreGroups extends ExploreEvent {
  final String userId;
  final List<String>? categories;

  const LoadExploreGroups({required this.userId, this.categories});

  @override
  List<Object?> get props => [userId, categories];
}
