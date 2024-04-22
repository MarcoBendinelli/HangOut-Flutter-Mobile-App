part of 'notification_cubit.dart';

enum NotificationStatus { initial, loading, success, error }

class NotificationState extends Equatable {
  final NotificationStatus status;

  const NotificationState({this.status = NotificationStatus.initial});

  @override
  List<Object> get props => [status];

  NotificationState copyWith({
    required NotificationStatus status,
  }) {
    return NotificationState(
      status: status,
    );
  }
}
