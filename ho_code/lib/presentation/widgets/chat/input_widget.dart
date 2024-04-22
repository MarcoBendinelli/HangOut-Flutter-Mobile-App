import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/chat/chat_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/notification/notification_cubit.dart';
import 'package:hang_out_app/data/models/message.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/data/models/user_data.dart';

class InputWidget extends StatefulWidget {
  final String iD;
  final bool isForTheGroup;
  final String chatName;
  final List<String> memberIdsToNotify;
  final String? eventCategory;
  final bool isForTablet;

  const InputWidget(
      {Key? key,
      required this.iD,
      required this.isForTheGroup,
      required this.chatName,
      required this.memberIdsToNotify,
      this.eventCategory,
      this.isForTablet = false})
      : super(key: key);

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  final messageTextController = TextEditingController();

  String messageText = "";

  @override
  Widget build(BuildContext context) {
    UserData currentUser = context.select((UserBloc bloc) => bloc.state.user);

    String senderId = currentUser.id;
    String senderNickname = currentUser.name;
    String senderPhoto = currentUser.photo;

    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                ChatCubit(chatRepository: context.read<ChatRepository>()),
          ),
          BlocProvider<NotificationCubit>(
            create: (context) => NotificationCubit(
                notificationsRepository:
                    context.read<NotificationsRepository>(),
                userRepository: context.read<UserRepository>()),
          ),
        ],
        child: !widget.isForTablet
            ? inputPhoneWidget(
                senderId: senderId,
                senderNickname: senderNickname,
                senderPhoto: senderPhoto,
                currentUser: currentUser)
            : inputTabletWidget(
                senderId: senderId,
                senderNickname: senderNickname,
                senderPhoto: senderPhoto,
                currentUser: currentUser));
  }

  Widget inputPhoneWidget(
      {required String senderId,
      required String senderNickname,
      required String senderPhoto,
      required UserData currentUser}) {
    return Builder(builder: (context) {
      return Container(
        // height: 40.h,
        color: Theme.of(context).colorScheme.secondary,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 20.0.w,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0.h),
                child: Container(
                  // height: 30.h,
                  // width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      // textInputAction: TextInputAction.done,
                      // onEditingComplete: () {
                      //   onTapFunction(
                      //       context: context,
                      //       senderId: senderId,
                      //       senderNickname: senderNickname,
                      //       senderPhoto: senderPhoto,
                      //       currentUser: currentUser);
                      // },
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Enter a message...',
                        border: InputBorder.none,
                        labelStyle: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                        //contentPadding: EdgeInsets.zero,
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: null,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0.w),
              child: TapFadeIcon(
                  onTap: () async {
                    onTapFunction(
                        context: context,
                        senderId: senderId,
                        senderNickname: senderNickname,
                        senderPhoto: senderPhoto,
                        currentUser: currentUser);
                  },
                  icon: AppIcons.arrowCircleUpOutline,
                  iconColor: Theme.of(context).colorScheme.onSecondary,
                  size: Constants.iconDimension),
            ),
          ],
        ),
      );
    });
  }

  Widget inputTabletWidget(
      {required String senderId,
      required String senderNickname,
      required String senderPhoto,
      required UserData currentUser}) {
    return Container(
      // height: 40.h,
      decoration: BoxDecoration(
        borderRadius: MediaQuery.of(context).viewInsets.bottom != 0
            ? null
            : const BorderRadius.only(
                bottomLeft: Radius.circular((Constants.borderRadius)),
                bottomRight: Radius.circular((Constants.borderRadius))),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: PopupTabletConstants.resize(40),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0.h),
              child: Container(
                // height: 30.h,
                // width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:
                      BorderRadius.circular(PopupTabletConstants.resize(20)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: PopupTabletConstants.resize(10)),
                  child: TextField(
                    style: TextStyle(fontSize: PopupTabletConstants.resize(16)),
                    controller: messageTextController,
                    onChanged: (value) {
                      messageText = value;
                    },
                    // textInputAction: TextInputAction.done,
                    // onEditingComplete: () {
                    //   onTapFunction(
                    //       context: context,
                    //       senderId: senderId,
                    //       senderNickname: senderNickname,
                    //       senderPhoto: senderPhoto,
                    //       currentUser: currentUser);
                    // },
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Enter a message...',
                      border: InputBorder.none,
                      labelStyle: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: PopupTabletConstants.resize(16)),
                      //contentPadding: EdgeInsets.zero,
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: null,
                  ),
                ),
              ),
            ),
          ),
          Builder(builder: (context) {
            return Padding(
              padding: EdgeInsets.only(
                  right: PopupTabletConstants.resize(20),
                  left: PopupTabletConstants.resize(20)),
              child: TapFadeIcon(
                  onTap: () async {
                    onTapFunction(
                        context: context,
                        senderId: senderId,
                        senderNickname: senderNickname,
                        senderPhoto: senderPhoto,
                        currentUser: currentUser);
                  },
                  icon: AppIcons.arrowCircleUpOutline,
                  iconColor: Theme.of(context).colorScheme.onSecondary,
                  size: PopupTabletConstants.resize(30)),
            );
          }),
        ],
      ),
    );
  }

  void onTapFunction(
      {required BuildContext context,
      required String senderId,
      required String senderNickname,
      required String senderPhoto,
      required UserData currentUser}) async {
    if (messageTextController.text.isNotEmpty) {
      String message = messageText;
      messageTextController.clear();
      List<String> membersToNotify = widget.memberIdsToNotify;

      DateTime now = DateTime.now();
      int timeStamp = now.millisecondsSinceEpoch;
      List<String> splitDateHour = now.toString().split(".")[0].split(":");
      String dateHour = "${splitDateHour[0]}:${splitDateHour[1]}";

      widget.isForTheGroup
          ? await BlocProvider.of<ChatCubit>(context).newGroupTextMessage(
              message: TextMessage(
                timeStamp: timeStamp,
                senderId: senderId,
                senderNickname: senderNickname,
                senderPhoto: senderPhoto,
                text: message,
                dateHour: dateHour,
              ),
              groupId: widget.iD)
          : await BlocProvider.of<ChatCubit>(context).newEventTextMessage(
              message: TextMessage(
                timeStamp: timeStamp,
                senderId: senderId,
                senderNickname: senderNickname,
                senderPhoto: senderPhoto,
                text: message,
                dateHour: dateHour,
              ),
              eventId: widget.iD);

      membersToNotify.remove(currentUser.id);

      if (mounted && membersToNotify.isNotEmpty) {
        /// Add a notification in the popup notifications
        if (widget.isForTheGroup) {
          BlocProvider.of<NotificationCubit>(context).addNewNotification(
              public: false,
              userIdsToNotify: membersToNotify,
              sourceName: senderNickname,
              thingToOpenId: widget.iD,
              thingToNotifyName: widget.chatName,
              dateHour: dateHour,
              timestamp: timeStamp,
              eventCategory: widget.eventCategory,
              chatMessage: message,
              notificationsGroupChat: true);

          /// Send a Push Notification
          BlocProvider.of<UserBloc>(context).sendPushNotificationsToUsers(
              userIdsToNotify: membersToNotify,
              title: currentUser.name + Constants.titleNotificationChat,
              body: widget.isForTheGroup
                  ? Constants.bodyNotificationChatGroup + widget.chatName
                  : Constants.bodyNotificationChatEvent + widget.chatName,
              notificationsGroupChat: true);
        } else {
          /// Add a notification in the popup notifications
          BlocProvider.of<NotificationCubit>(context).addNewNotification(
              public: false,
              userIdsToNotify: membersToNotify,
              sourceName: senderNickname,
              thingToOpenId: widget.iD,
              thingToNotifyName: widget.chatName,
              dateHour: dateHour,
              timestamp: timeStamp,
              eventCategory: widget.eventCategory,
              chatMessage: message,
              notificationsEventChat: true);

          /// Send a Push Notification
          BlocProvider.of<UserBloc>(context).sendPushNotificationsToUsers(
              userIdsToNotify: membersToNotify,
              title: currentUser.name + Constants.titleNotificationChat,
              body: widget.isForTheGroup
                  ? Constants.bodyNotificationChatGroup + widget.chatName
                  : Constants.bodyNotificationChatEvent + widget.chatName,
              notificationsEventChat: true);
        }
      }
    }
  }
}
