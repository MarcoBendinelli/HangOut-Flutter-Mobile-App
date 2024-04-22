part of 'specific_group_event_bloc.dart';

abstract class SpecificGroupEventState extends Equatable {
  const SpecificGroupEventState();

  @override
  List<Object?> get props => [];
}

class SpecificGroupEventLoading extends SpecificGroupEventState {}

class SpecificGroupEventError extends SpecificGroupEventState {}

class SpecificGroupEventLoaded extends SpecificGroupEventState {
  final Group? group;
  final Event? event;

  const SpecificGroupEventLoaded({this.group, this.event});

  @override
  List<Object?> get props => [group, event];
}
