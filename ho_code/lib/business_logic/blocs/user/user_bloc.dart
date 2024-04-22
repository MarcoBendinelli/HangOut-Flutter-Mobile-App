import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/data/services/notification_service.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;
  final NotificationService _notificationService;

  UserBloc(
      {required UserRepository userRepository,
      required NotificationService notificationService})
      : _userRepository = userRepository,
        _notificationService = notificationService,
        super(UserLoading()) {
    on<LoadUser>(_onLoadUser);
  }

  Future<void> _onLoadUser(
    LoadUser event,
    Emitter<UserState> emit,
  ) async {
    await emit.forEach(
      _userRepository.getUserDataStream(event.userId),
      onData: (UserData eventData) => UserLoaded(user: eventData),
      onError: (_, __) => UserLoadingError(),
    );
  }

  Future<List<String>> getInterestedUsersToNotify(
      {required List<String> newGroupEventInterests}) async {
    return await _userRepository.getInterestedUsersToNotify(
        newGroupEventInterests: newGroupEventInterests);
  }

  initializeNotification({required String currentUserId}) async {
    await _notificationService.firstInitialization(currentUserId);
  }

  setNotificationsServiceOnNotInitialized() {
    _notificationService.setOnNotInitialized();
  }

  setOnClickNotifications(
      {required Function onClickGroupNotification,
      required Function onClickEventNotification,
      required Function onClickChatGroupNotification,
      required Function onClickChatEventNotification,
      required Function onClickPublicGroupNotification}) async {
    await _notificationService.setNotificationsBehaviour(
      onClickGroupNotification: onClickGroupNotification,
      onClickEventNotification: onClickEventNotification,
      onClickChatGroupNotification: onClickChatGroupNotification,
      onClickChatEventNotification: onClickChatEventNotification,
      onClickPublicGroupNotification: onClickPublicGroupNotification,
    );
  }

  sendPushNotificationsToUsers({
    required List<String> userIdsToNotify,
    required String title,
    required String body,
    bool notificationsEventChat = false,
    bool notificationsGroupChat = false,
    bool notificationsInviteEvent = false,
    bool notificationsJoinGroup = false,
    bool notificationsPublicEvent = false,
    bool notificationsPublicGroup = false,
  }) async {
    for (String id in userIdsToNotify) {
      UserData user = await _userRepository.getUserData(id);
      if (user.notificationsPush) {
        if ((user.notificationsEventChat && notificationsEventChat)) {
          sendPushNotification(id: id, title: title, body: body);
        } else if ((user.notificationsGroupChat && notificationsGroupChat)) {
          sendPushNotification(id: id, title: title, body: body);
        } else if ((user.notificationsInviteEvent &&
            notificationsInviteEvent)) {
          sendPushNotification(id: id, title: title, body: body);
        } else if ((user.notificationsJoinGroup && notificationsJoinGroup)) {
          sendPushNotification(id: id, title: title, body: body);
        } else if ((user.notificationsPublicEvent &&
            notificationsPublicEvent)) {
          sendPushNotification(id: id, title: title, body: body);
        } else if ((user.notificationsPublicGroup &&
            notificationsPublicGroup)) {
          sendPushNotification(id: id, title: title, body: body);
        }
      }
    }
  }

  sendPushNotification({
    required String id,
    required String title,
    required String body,
  }) async {
    try {
      List<String> tokens;
      tokens = await _notificationService.getTokenOfUser(id);
      for (String token in tokens) {
        await _notificationService.sendPushMessage(
            token: token, title: title, body: body);
      }
    } catch (e) {
      debugPrint("Token not set for the user: $id");
    }
  }
}
