part of 'notifications_bloc.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object> get props => [];
}

class NotificationsLoading extends NotificationsState {}

class NotificationsError extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<OurNotification> notifications;

  const NotificationsLoaded({required this.notifications});

  @override
  List<Object> get props => [notifications];
}
