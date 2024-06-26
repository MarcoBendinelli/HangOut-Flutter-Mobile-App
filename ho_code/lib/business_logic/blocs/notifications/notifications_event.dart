part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
}

class LoadNotifications extends NotificationsEvent {
  final String userId;

  const LoadNotifications({required this.userId});

  @override
  List<Object> get props => [userId];
}
