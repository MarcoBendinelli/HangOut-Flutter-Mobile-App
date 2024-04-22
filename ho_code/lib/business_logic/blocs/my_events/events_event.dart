part of 'events_bloc.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();
}

class LoadEvents extends EventsEvent {
  final String userId;

  const LoadEvents({required this.userId});

  @override
  List<Object> get props => [userId];
}
