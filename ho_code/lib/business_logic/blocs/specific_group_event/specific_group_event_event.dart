part of 'specific_group_event_bloc.dart';

abstract class SpecificGroupEventEvent extends Equatable {
  const SpecificGroupEventEvent();
}

class LoadSpecificGroup extends SpecificGroupEventEvent {
  final String groupId;

  const LoadSpecificGroup({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class LoadSpecificEvent extends SpecificGroupEventEvent {
  final String eventId;

  const LoadSpecificEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}
