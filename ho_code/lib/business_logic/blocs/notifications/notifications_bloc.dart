import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';

part 'notifications_event.dart';

part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _notificationsRepository;

  NotificationsBloc({required NotificationsRepository notificationsRepository})
      : _notificationsRepository = notificationsRepository,
        super(NotificationsLoading()) {
    on<LoadNotifications>(_onLoadNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    await emit.forEach(
      await _notificationsRepository.getNotifications(event.userId),
      onData: (List<OurNotification> notificationData) =>
          NotificationsLoaded(notifications: notificationData),
      onError: (_, __) => NotificationsError(),
    );
  }
}
