import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/notification/notification_cubit.dart';
import 'package:hang_out_app/presentation/utils/animations/from_right_page_route.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/chat/chat_view.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/popups/chat_tablet_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_event_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_group_popup.dart';

class NotificationRow extends StatelessWidget {
  final String sourceName;
  final String thingToNotify;
  final String? category;
  final bool hasBottomBorder;
  final String id;
  final String notificationId;
  final String hour;
  final bool public;
  final String? chatMessage;

  const NotificationRow(
      {super.key,
      required this.sourceName,
      required this.thingToNotify,
      this.category,
      this.hasBottomBorder = false,
      required this.id,
      required this.notificationId,
      required this.hour,
      required this.chatMessage,
      required this.public});

  void onTapFunction(BuildContext context) {
    if (chatMessage == "") {
      if (!public) {
        if (category == "") {
          Navigator.of(context).push(FromRightPageRoute(
              builder: (BuildContext context) => SingleGroupPopup(
                    heroTag: "GroupPopup",
                    groupId: id,
                  )));
        } else {
          Navigator.of(context).push(FromRightPageRoute(
              builder: (BuildContext context) => SingleEventPopup(
                    heroTag: "EventPopup",
                    eventId: id,
                    fromNotification: true,
                    fromExplore: true,
                  )));
        }
      } else {
        if (category == "") {
          Navigator.of(context).push(
            FromRightPageRoute(
              builder: (newContext) => SingleGroupPopup(
                heroTag: 'grouPopup',
                groupId: id,
                fromExplore: true,
                fromNotification: true,
              ),
            ),
          );
        } else {
          Navigator.of(context).push(FromRightPageRoute(
              builder: (BuildContext context) => SingleEventPopup(
                    heroTag: "EventPopup",
                    eventId: id,
                    fromNotification: true,
                    fromExplore: true,
                  )));
        }
      }
    } else {
      if (category == "") {
        Navigator.pop(context);
        Navigator.push(
            context,
            CupertinoPageRoute<bool>(
                builder: (_) => ChatView(
                      id: id,
                      isForTheGroup: true,
                      chatName: thingToNotify,
                    )));
      } else {
        Navigator.pop(context);
        Navigator.push(
            context,
            CupertinoPageRoute<bool>(
                builder: (_) => ChatView(
                      id: id,
                      isForTheGroup: false,
                      chatName: thingToNotify,
                    )));
      }
    }
  }

  void onTapTabletFunction(BuildContext context) {
    if (chatMessage == "") {
      if (!public) {
        if (category == "") {
          Navigator.of(context).push(FromRightPageRoute(
              builder: (BuildContext context) => SingleGroupPopup(
                    heroTag: "GroupPopup",
                    groupId: id,
                  )));
        } else {
          Navigator.of(context).push(FromRightPageRoute(
              builder: (BuildContext context) => SingleEventPopup(
                    heroTag: "EventPopup",
                    eventId: id,
                    fromNotification: true,
                    fromExplore: true,
                  )));
        }
      } else {
        if (category == "") {
          Navigator.of(context).push(
            FromRightPageRoute(
              builder: (newContext) => SingleGroupPopup(
                heroTag: 'grouPopup',
                groupId: id,
                fromExplore: true,
                fromNotification: true,
              ),
            ),
          );
        } else {
          Navigator.of(context).push(FromRightPageRoute(
              builder: (BuildContext context) => SingleEventPopup(
                    heroTag: "EventPopup",
                    eventId: id,
                    fromNotification: true,
                    fromExplore: true,
                  )));
        }
      }
    } else {
      if (category == "") {
        Navigator.of(context).push(FromRightPageRoute(
            builder: (newContext) => ChatTabletPopup(
                  heroTag: 'Chat view Popup',
                  id: id,
                  isForTheGroup: true,
                  chatName: thingToNotify,
                )));
      } else {
        Navigator.of(context).push(FromRightPageRoute(
            builder: (newContext) => ChatTabletPopup(
                  heroTag: 'Chat view Popup',
                  id: id,
                  isForTheGroup: false,
                  chatName: thingToNotify,
                )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId =
        context.select((UserBloc bloc) => bloc.state.user.id);

    if (getSize(context) == ScreenSize.normal) {
      /// Phone
      return Dismissible(
        key: UniqueKey(),
        background: Container(
          color: Theme.of(context).dividerColor,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 30.0.w),
              child: Icon(
                AppIcons.close,
                color: Theme.of(context).cardColor,
                size: Constants.iconDimension,
              ),
            ),
          ),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          BlocProvider.of<NotificationCubit>(context).deleteNotification(
              idNotification: notificationId, currentUserId: currentUserId);
        },
        child: GestureDetector(
          onTap: () {
            onTapFunction(context);
          },
          child: Container(
              height: 90.0.h,
              decoration: BoxDecoration(
                color: category == ""
                    ? Theme.of(context).cardColor
                    : CategoryColors.getColor(category!),
                border: hasBottomBorder
                    ? Border(
                        bottom: BorderSide(
                          color: Theme.of(context).hintColor,
                          width: 1.0,
                        ),
                      )
                    : null,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 20.0.w, right: 20.0.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.arrowIosForwardOutline,
                            size: Constants.iconDimension,
                            color: category == "other"
                                ? AppColors.whiteColor
                                : category == ""
                                    ? null
                                    : AppColors.blackColor,
                          ),
                          SizedBox(
                            width: 15.0.w,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    chatMessage != ""
                                        ? Expanded(
                                            child: CustomText(
                                              text:
                                                  "New message from $thingToNotify",
                                              fontFamily: "Raleway",
                                              fontWeight: Fonts.medium,
                                              size: 14.r,
                                              overflow: TextOverflow.ellipsis,
                                              color: category == "other"
                                                  ? AppColors.whiteColor
                                                  : category == ""
                                                      ? null
                                                      : AppColors.blackColor,
                                            ),
                                          )
                                        : public == false
                                            ? category == ""
                                                ? CustomText(
                                                    text:
                                                        "You've been added to a new group",
                                                    fontFamily: "Raleway",
                                                    fontWeight: Fonts.medium,
                                                    size: 14.r,
                                                    color: category == "other"
                                                        ? AppColors.whiteColor
                                                        : category == ""
                                                            ? null
                                                            : AppColors
                                                                .blackColor,
                                                  )
                                                : CustomText(
                                                    text:
                                                        "New invitation to an event",
                                                    fontFamily: "Raleway",
                                                    fontWeight: Fonts.medium,
                                                    size: 14.r,
                                                    color: category == "other"
                                                        ? AppColors.whiteColor
                                                        : category == ""
                                                            ? null
                                                            : AppColors
                                                                .blackColor,
                                                  )
                                            : category == ""
                                                ? CustomText(
                                                    text:
                                                        "A new group was published",
                                                    fontFamily: "Raleway",
                                                    fontWeight: Fonts.medium,
                                                    size: 14.r,
                                                    color: category == "other"
                                                        ? AppColors.whiteColor
                                                        : category == ""
                                                            ? null
                                                            : AppColors
                                                                .blackColor,
                                                  )
                                                : CustomText(
                                                    text:
                                                        "A new event was published",
                                                    fontFamily: "Raleway",
                                                    fontWeight: Fonts.medium,
                                                    size: 14.r,
                                                    color: category == "other"
                                                        ? AppColors.whiteColor
                                                        : category == ""
                                                            ? null
                                                            : AppColors
                                                                .blackColor,
                                                  ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    CustomText(
                                      text: "$sourceName: ",
                                      fontFamily: "Raleway",
                                      fontWeight: Fonts.regular,
                                      size: 14.r,
                                      color: category == "other"
                                          ? AppColors.whiteColor
                                          : category == ""
                                              ? null
                                              : AppColors.blackColor,
                                    ),
                                    chatMessage == ""
                                        ? Expanded(
                                            child: CustomText(
                                              text: thingToNotify,
                                              fontFamily: "Raleway",
                                              fontWeight: Fonts.bold,
                                              size: 14.r,
                                              overflow: TextOverflow.ellipsis,
                                              color: category == "other"
                                                  ? AppColors.whiteColor
                                                  : category == ""
                                                      ? null
                                                      : AppColors.blackColor,
                                            ),
                                          )
                                        : Expanded(
                                            child: CustomText(
                                              text: chatMessage!,
                                              fontFamily: "Raleway",
                                              fontWeight: Fonts.bold,
                                              size: 14.r,
                                              overflow: TextOverflow.ellipsis,
                                              color: category == "other"
                                                  ? AppColors.whiteColor
                                                  : category == ""
                                                      ? null
                                                      : AppColors.blackColor,
                                            ),
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 5.r,
                    ),
                    CustomText(
                      text: hour,
                      fontFamily: "Raleway",
                      fontWeight: Fonts.regular,
                      size: 10.r,
                      color: category == "other"
                          ? AppColors.whiteColor
                          : category == ""
                              ? null
                              : AppColors.blackColor,
                    )
                  ],
                ),
              )),
        ),
      );
    }

    /// Tablet
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Theme.of(context).dividerColor,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: PopupTabletConstants.resize(30)),
            child: Icon(
              AppIcons.close,
              color: Theme.of(context).cardColor,
              size: TabletConstants.iconDimension(),
            ),
          ),
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        BlocProvider.of<NotificationCubit>(context).deleteNotification(
            idNotification: notificationId, currentUserId: currentUserId);
      },
      child: GestureDetector(
        onTap: () {
          onTapTabletFunction(context);
        },
        child: Container(
            height: PopupTabletConstants.resize(90),
            decoration: BoxDecoration(
              color: category == ""
                  ? Theme.of(context).cardColor
                  : CategoryColors.getColor(category!),
              border: hasBottomBorder
                  ? Border(
                      bottom: BorderSide(
                        color: Theme.of(context).hintColor,
                        width: 1.0,
                      ),
                    )
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  left: PopupTabletConstants.resize(20),
                  right: PopupTabletConstants.resize(20)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.arrowIosForwardOutline,
                          size: Constants.iconDimension,
                          color: category == "other"
                              ? AppColors.whiteColor
                              : category == ""
                                  ? null
                                  : AppColors.blackColor,
                        ),
                        SizedBox(
                          width: PopupTabletConstants.resize(15),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  chatMessage != ""
                                      ? Expanded(
                                          child: CustomText(
                                            text:
                                                "New message from $thingToNotify",
                                            fontFamily: "Raleway",
                                            fontWeight: Fonts.medium,
                                            size:
                                                PopupTabletConstants.resize(16),
                                            overflow: TextOverflow.ellipsis,
                                            color: category == "other"
                                                ? AppColors.whiteColor
                                                : category == ""
                                                    ? null
                                                    : AppColors.blackColor,
                                          ),
                                        )
                                      : public == false
                                          ? category == ""
                                              ? CustomText(
                                                  text:
                                                      "You've been added to a new group",
                                                  fontFamily: "Raleway",
                                                  fontWeight: Fonts.medium,
                                                  size: PopupTabletConstants
                                                      .resize(16),
                                                  color: category == "other"
                                                      ? AppColors.whiteColor
                                                      : category == ""
                                                          ? null
                                                          : AppColors
                                                              .blackColor,
                                                )
                                              : CustomText(
                                                  text:
                                                      "New invitation to an event",
                                                  fontFamily: "Raleway",
                                                  fontWeight: Fonts.medium,
                                                  size: PopupTabletConstants
                                                      .resize(16),
                                                  color: category == "other"
                                                      ? AppColors.whiteColor
                                                      : category == ""
                                                          ? null
                                                          : AppColors
                                                              .blackColor,
                                                )
                                          : category == ""
                                              ? CustomText(
                                                  text:
                                                      "A new group was published",
                                                  fontFamily: "Raleway",
                                                  fontWeight: Fonts.medium,
                                                  size: PopupTabletConstants
                                                      .resize(16),
                                                  color: category == "other"
                                                      ? AppColors.whiteColor
                                                      : category == ""
                                                          ? null
                                                          : AppColors
                                                              .blackColor,
                                                )
                                              : CustomText(
                                                  text:
                                                      "A new event was published",
                                                  fontFamily: "Raleway",
                                                  fontWeight: Fonts.medium,
                                                  size: PopupTabletConstants
                                                      .resize(16),
                                                  color: category == "other"
                                                      ? AppColors.whiteColor
                                                      : category == ""
                                                          ? null
                                                          : AppColors
                                                              .blackColor,
                                                ),
                                ],
                              ),
                              Row(
                                children: [
                                  CustomText(
                                    text: "$sourceName: ",
                                    fontFamily: "Raleway",
                                    fontWeight: Fonts.regular,
                                    size: PopupTabletConstants.resize(16),
                                    color: category == "other"
                                        ? AppColors.whiteColor
                                        : category == ""
                                            ? null
                                            : AppColors.blackColor,
                                  ),
                                  chatMessage == ""
                                      ? Expanded(
                                          child: CustomText(
                                            text: thingToNotify,
                                            fontFamily: "Raleway",
                                            fontWeight: Fonts.bold,
                                            size:
                                                PopupTabletConstants.resize(16),
                                            overflow: TextOverflow.ellipsis,
                                            color: category == "other"
                                                ? AppColors.whiteColor
                                                : category == ""
                                                    ? null
                                                    : AppColors.blackColor,
                                          ),
                                        )
                                      : Expanded(
                                          child: CustomText(
                                            text: chatMessage!,
                                            fontFamily: "Raleway",
                                            fontWeight: Fonts.bold,
                                            size:
                                                PopupTabletConstants.resize(16),
                                            overflow: TextOverflow.ellipsis,
                                            color: category == "other"
                                                ? AppColors.whiteColor
                                                : category == ""
                                                    ? null
                                                    : AppColors.blackColor,
                                          ),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: PopupTabletConstants.resize(5),
                  ),
                  CustomText(
                    text: hour,
                    fontFamily: "Raleway",
                    fontWeight: Fonts.regular,
                    size: PopupTabletConstants.resize(12),
                    color: category == "other"
                        ? AppColors.whiteColor
                        : category == ""
                            ? null
                            : AppColors.blackColor,
                  )
                ],
              ),
            )),
      ),
    );
  }
}
