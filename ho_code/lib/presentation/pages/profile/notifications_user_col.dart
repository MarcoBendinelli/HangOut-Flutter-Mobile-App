import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/pages/profile/notification_user_row.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class NotificationsUserCol extends StatelessWidget {
  final bool notificationsPush;
  final bool notificationsGroupChat;
  final bool notificationsEventChat;
  final bool notificationsJoinGroup;
  final bool notificationsInviteEvent;
  final bool notificationsPublicEvent;
  final bool notificationsPublicGroup;
  final Function callbackPush;
  final Function callbackGroupChat;
  final Function callbackEventChat;
  final Function callbackJoinGroup;
  final Function callbackInviteEvent;
  final Function callbackPublicEvent;
  final Function callbackPublicGroup;

  const NotificationsUserCol(
      {super.key,
      required this.notificationsPush,
      required this.notificationsGroupChat,
      required this.notificationsEventChat,
      required this.notificationsJoinGroup,
      required this.notificationsInviteEvent,
      required this.notificationsPublicEvent,
      required this.notificationsPublicGroup,
      required this.callbackPush,
      required this.callbackGroupChat,
      required this.callbackEventChat,
      required this.callbackJoinGroup,
      required this.callbackInviteEvent,
      required this.callbackPublicEvent,
      required this.callbackPublicGroup});

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildNotificationsCol();
    }
    return _buildTabletNotificationsCol();
  }

  Widget _buildNotificationsCol() {
    return Column(
      key: const Key("Notifications_column"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Notifications:',
          size: Constants.textDimensionTitle,
          fontWeight: Fonts.bold,
          fontFamily: "Raleway",
        ),
        NotificationUserRow(
          initEnabled: notificationsPush,
          notificationText: 'Push notifications',
          callback: (bool isEnabled) {
            callbackPush(isEnabled);
          },
        ),
        NotificationUserRow(
          initEnabled: notificationsGroupChat,
          notificationText: 'New message from group-chat',
          callback: (bool isEnabled) {
            callbackGroupChat(isEnabled);
          },
        ),
        NotificationUserRow(
          initEnabled: notificationsEventChat,
          notificationText: 'New message from event-chat',
          callback: (bool isEnabled) {
            callbackEventChat(isEnabled);
          },
        ),
        NotificationUserRow(
          initEnabled: notificationsJoinGroup,
          notificationText: 'New join to a group',
          callback: (bool isEnabled) {
            callbackJoinGroup(isEnabled);
          },
        ),
        NotificationUserRow(
          initEnabled: notificationsInviteEvent,
          notificationText: 'New invitation to an event',
          callback: (bool isEnabled) {
            callbackInviteEvent(isEnabled);
          },
        ),
        NotificationUserRow(
          initEnabled: notificationsPublicEvent,
          notificationText: 'New public event by interests',
          callback: (bool isEnabled) {
            callbackPublicEvent(isEnabled);
          },
          notificationDescriptionFirstRow:
              '*It sends notifications only about public events',
          notificationDescriptionSecondRow: 'related to your interests',
        ),
        NotificationUserRow(
          initEnabled: notificationsPublicGroup,
          notificationText: 'New public group by interests',
          callback: (bool isEnabled) {
            callbackPublicGroup(isEnabled);
          },
          notificationDescriptionFirstRow:
              '*It sends notifications only about public groups',
          notificationDescriptionSecondRow: 'related to your interests',
        ),
      ],
    );
  }

  Widget _buildTabletNotificationsCol() {
    return Column(
      key: const Key("Notifications_column"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Notifications:',
          size: TabletConstants.textDimensionGroupName(),
          fontWeight: Fonts.bold,
          fontFamily: "Raleway",
        ),
        NotificationUserRow(
          initEnabled: notificationsPush,
          notificationText: 'Push notifications',
          callback: (bool isEnabled) {
            callbackPush(isEnabled);
          },
        ),
        NotificationUserRow(
          initEnabled: notificationsGroupChat,
          notificationText: 'New message from group-chat',
          callback: (bool isEnabled) {
            callbackGroupChat(isEnabled);
          },
        ),
        NotificationUserRow(
          initEnabled: notificationsEventChat,
          notificationText: 'New message from event-chat',
          callback: (bool isEnabled) {
            callbackEventChat(isEnabled);
          },
        ),
        NotificationUserRow(
          initEnabled: notificationsJoinGroup,
          notificationText: 'New join to a group',
          callback: (bool isEnabled) {
            callbackJoinGroup(isEnabled);
          },
        ),
        NotificationUserRow(
          initEnabled: notificationsInviteEvent,
          notificationText: 'New invitation to an event',
          callback: (bool isEnabled) {
            callbackInviteEvent(isEnabled);
          },
        ),
        NotificationUserRow(
          initEnabled: notificationsPublicEvent,
          notificationText: 'New public event by interests',
          callback: (bool isEnabled) {
            callbackPublicEvent(isEnabled);
          },
          notificationDescriptionFirstRow:
              '*It sends notifications only about public events',
          notificationDescriptionSecondRow: 'related to your interests',
        ),
        NotificationUserRow(
          initEnabled: notificationsPublicGroup,
          notificationText: 'New public group by interests',
          callback: (bool isEnabled) {
            callbackPublicGroup(isEnabled);
          },
          notificationDescriptionFirstRow:
              '*It sends notifications only about public groups',
          notificationDescriptionSecondRow: 'related to your interests',
        ),
      ],
    );
  }
}
