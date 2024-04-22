import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/notifications/notifications_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/notification/notification_cubit.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_return_and_name.dart';
import 'package:hang_out_app/presentation/utils/animations/custom_rect_tween.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/date_in_notifications_and_chat.dart';
import 'package:hang_out_app/presentation/widgets/popups/notifications/notification_row.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import "package:collection/collection.dart";
import 'package:intl/intl.dart';

class NotificationsPopup extends StatefulWidget {
  final String heroTag;

  const NotificationsPopup({Key? key, required this.heroTag}) : super(key: key);

  @override
  State<NotificationsPopup> createState() => _NotificationsPopupState();
}

class _NotificationsPopupState extends State<NotificationsPopup> {
  List<String> membersToNotify = [];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotificationCubit>(
          create: (context) => NotificationCubit(
              notificationsRepository: context.read<NotificationsRepository>(),
              userRepository: context.read<UserRepository>()),
        ),
      ],
      child: getSize(context) == ScreenSize.normal
          ? _buildPopup()
          : _buildTabletPopup(),
    );
  }

  Widget _buildPopup() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: Constants.popupDimensionPadding,
          child: Hero(
            tag: widget.heroTag,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin!, end: end!);
            },
            child: Material(
              color: Theme.of(context).cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.borderRadius)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(builder: (context) {
                    return const TopBarReturnAndName(
                      title: 'Notifications',
                    );
                  }),
                  BlocBuilder<NotificationsBloc, NotificationsState>(
                    builder: (context, state) {
                      if (state is NotificationsLoading) {
                        return const Center(
                          child: OurCircularProgressIndicator(),
                        );
                      } else if (state is NotificationsLoaded) {
                        List<Widget> rows = [];

                        final List<OurNotification> notifications =
                            state.notifications;
                        notifications.sort((a, b) => b.timestamp - a.timestamp);

                        var groupByDate = groupBy(notifications,
                            (obj) => obj.dateHour.substring(0, 10));
                        DateTime now = DateTime.now();

                        groupByDate.forEach((date, notifications) {
                          DateTime parsedDate = DateTime.parse(date);

                          /// Header
                          if (now.difference(parsedDate).inDays == 1) {
                            rows.add(const DateInNotificationsAndChat(
                              date: "Yesterday",
                            ));
                          } else if (!DateUtils.isSameDay(now, parsedDate) &&
                              now.year == parsedDate.year) {
                            rows.add(DateInNotificationsAndChat(
                              date:
                                  "${DateFormat('EEEE').format(parsedDate)} ${parsedDate.day} ${DateFormat.MMMM().format(parsedDate)}",
                            ));
                          } else if (!DateUtils.isSameDay(now, parsedDate) &&
                              now.year != parsedDate.year) {
                            rows.add(DateInNotificationsAndChat(
                              date:
                                  "${DateFormat('EEEE').format(parsedDate)} ${parsedDate.day} ${DateFormat.MMMM().format(parsedDate)} ${parsedDate.year}",
                            ));
                          }

                          /// Group
                          for (var notification in notifications) {
                            final List<String> splitDateHour =
                                notification.dateHour.split(" ");
                            final String hour = splitDateHour[1];

                            /// List item
                            rows.add(
                              NotificationRow(
                                public: notification.public,
                                sourceName: notification.sourceName,
                                thingToNotify: notification.thingToNotifyName,
                                category: notification.eventCategory,
                                id: notification.thingToOpenId,
                                notificationId: notification.notificationId,
                                hour: hour,
                                hasBottomBorder: true,
                                chatMessage: notification.chatMessage,
                              ),
                            );
                          }
                        });

                        if (rows.isEmpty) {
                          return Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsets.only(top: Constants.heightError),
                              child:
                                  const CustomText(text: "No new notification"),
                            ),
                          );
                        } else {
                          return Expanded(
                              child: Padding(
                            padding: EdgeInsets.only(top: 3.5.h),
                            child: ListView(
                                padding: EdgeInsets.zero,
                                children: rows.reversed.toList()),
                          ));
                        }
                      } else {
                        return Expanded(
                          child: Padding(
                            padding:
                                EdgeInsets.only(top: Constants.heightError),
                            child: const CustomText(
                                text:
                                    "An error occurred while loading the notifications"),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletPopup() {
    return SafeArea(
      child: Center(
        child: Hero(
          tag: widget.heroTag,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
            color: Theme.of(context).cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.borderRadius)),
            child: SizedBox(
              height: PopupTabletConstants.popupDimension(),
              width: PopupTabletConstants.popupDimension(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(builder: (context) {
                    return const TopBarReturnAndName(
                      title: 'Notifications',
                    );
                  }),
                  BlocBuilder<NotificationsBloc, NotificationsState>(
                    builder: (context, state) {
                      if (state is NotificationsLoading) {
                        return const Center(
                          child: OurCircularProgressIndicator(),
                        );
                      } else if (state is NotificationsLoaded) {
                        List<Widget> rows = [];

                        final List<OurNotification> notifications =
                            state.notifications;
                        notifications.sort((a, b) => b.timestamp - a.timestamp);

                        var groupByDate = groupBy(notifications,
                            (obj) => obj.dateHour.substring(0, 10));
                        DateTime now = DateTime.now();

                        groupByDate.forEach((date, notifications) {
                          DateTime parsedDate = DateTime.parse(date);

                          /// Header
                          if (now.difference(parsedDate).inDays == 1) {
                            rows.add(const DateInNotificationsAndChat(
                              date: "Yesterday",
                            ));
                          } else if (!DateUtils.isSameDay(now, parsedDate) &&
                              now.year == parsedDate.year) {
                            rows.add(DateInNotificationsAndChat(
                              date:
                                  "${DateFormat('EEEE').format(parsedDate)} ${parsedDate.day} ${DateFormat.MMMM().format(parsedDate)}",
                            ));
                          } else if (!DateUtils.isSameDay(now, parsedDate) &&
                              now.year != parsedDate.year) {
                            rows.add(DateInNotificationsAndChat(
                              date:
                                  "${DateFormat('EEEE').format(parsedDate)} ${parsedDate.day} ${DateFormat.MMMM().format(parsedDate)} ${parsedDate.year}",
                            ));
                          }

                          /// Group
                          for (var notification in notifications) {
                            final List<String> splitDateHour =
                                notification.dateHour.split(" ");
                            final String hour = splitDateHour[1];

                            /// List item
                            rows.add(
                              NotificationRow(
                                sourceName: notification.sourceName,
                                thingToNotify: notification.thingToNotifyName,
                                category: notification.eventCategory,
                                id: notification.thingToOpenId,
                                notificationId: notification.notificationId,
                                hour: hour,
                                hasBottomBorder: true,
                                chatMessage: notification.chatMessage,
                                public: notification.public,
                              ),
                            );
                          }
                        });

                        if (rows.isEmpty) {
                          return Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsets.only(top: Constants.heightError),
                              child:
                                  const CustomText(text: "No new notification"),
                            ),
                          );
                        } else {
                          return Expanded(
                              child: Padding(
                            padding: EdgeInsets.only(
                                top: PopupTabletConstants.resize(3.5)),
                            child: ListView(
                                padding: EdgeInsets.zero,
                                children: rows.reversed.toList()),
                          ));
                        }
                      } else {
                        return Expanded(
                          child: Padding(
                            padding:
                                EdgeInsets.only(top: Constants.heightError),
                            child: const CustomText(
                                text:
                                    "An error occurred while loading the notifications"),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
