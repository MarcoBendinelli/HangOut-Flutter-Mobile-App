import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationsRepository _notificationsRepository;
  final UserRepository _userRepository;

  NotificationCubit(
      {required NotificationsRepository notificationsRepository,
      required UserRepository userRepository})
      : _notificationsRepository = notificationsRepository,
        _userRepository = userRepository,
        super(const NotificationState());

  Future<void> addNewNotification({
    required List<String> userIdsToNotify,
    required String sourceName,
    required String thingToOpenId,
    required String thingToNotifyName,
    required String dateHour,
    required int timestamp,
    required bool public,
    String? eventCategory,
    String? chatMessage,
    bool notificationsEventChat = false,
    bool notificationsGroupChat = false,
    bool notificationsInviteEvent = false,
    bool notificationsJoinGroup = false,
    bool notificationsPublicEvent = false,
    bool notificationsPublicGroup = false,
  }) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    List<String> idsWantNotification = [];

    for (String id in userIdsToNotify) {
      UserData user = await _userRepository.getUserData(id);

      if ((user.notificationsEventChat && notificationsEventChat)) {
        idsWantNotification.add(id);
      } else if ((user.notificationsGroupChat && notificationsGroupChat)) {
        idsWantNotification.add(id);
      } else if ((user.notificationsInviteEvent && notificationsInviteEvent)) {
        idsWantNotification.add(id);
      } else if ((user.notificationsJoinGroup && notificationsJoinGroup)) {
        idsWantNotification.add(id);
      } else if ((user.notificationsPublicEvent && notificationsPublicEvent)) {
        idsWantNotification.add(id);
      } else if ((user.notificationsPublicGroup && notificationsPublicGroup)) {
        idsWantNotification.add(id);
      }
    }

    if (idsWantNotification.isNotEmpty) {
      String category;
      String message;

      if (eventCategory == null) {
        category = "";
      } else {
        category = eventCategory;
      }
      if (chatMessage == null) {
        message = "";
      } else {
        message = chatMessage;
      }

      try {
        _notificationsRepository.addNewNotification(
            notification: OurNotification(
          userIds: idsWantNotification,
          thingToOpenId: thingToOpenId,
          thingToNotifyName: thingToNotifyName,
          sourceName: sourceName,
          notificationId: '',
          dateHour: dateHour,
          timestamp: timestamp,
          eventCategory: category,
          chatMessage: message,
          public: public,
        ));

        emit(state.copyWith(status: NotificationStatus.success));
      } catch (_) {
        emit(state.copyWith(status: NotificationStatus.error));
      }
    } else {
      emit(state.copyWith(status: NotificationStatus.success));
    }
  }

  Future<void> deleteNotification({
    required idNotification,
    required currentUserId,
  }) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    try {
      _notificationsRepository.removeUserFromNotification(
          idUser: currentUserId, idNotification: idNotification);
      emit(state.copyWith(status: NotificationStatus.success));
    } catch (_) {
      emit(state.copyWith(status: NotificationStatus.error));
    }
  }
}
