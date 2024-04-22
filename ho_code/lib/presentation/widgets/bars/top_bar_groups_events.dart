import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/notifications/notifications_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/presentation/utils/animations/from_top_page_route.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/popups/notifications/notifications_popup.dart';

class TopBarGroupsEventsPages extends StatefulWidget {
  final String title;
  final Function() onAddPress;

  const TopBarGroupsEventsPages({
    Key? key,
    required this.title,
    required this.onAddPress,
  }) : super(key: key);

  @override
  State<TopBarGroupsEventsPages> createState() =>
      _TopBarGroupsEventsPagesState();
}

class _TopBarGroupsEventsPagesState extends State<TopBarGroupsEventsPages> {
  bool areAnyNotifications = false;
  bool areNotificationsLoaded = false;

  @override
  Widget build(BuildContext context) {
    String currentUserId =
        context.select((UserBloc bloc) => bloc.state.user.id);

    return BlocProvider(
      create: (context) => NotificationsBloc(
          notificationsRepository: context.read<NotificationsRepository>())
        ..add(LoadNotifications(userId: currentUserId)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TapFadeIcon(
            key: const Key("add"),
            iconColor: Theme.of(context).iconTheme.color!,
            onTap: widget.onAddPress,
            icon: AppIcons.plusCircleOutline,
            size: Constants.iconDimension,
          ),
          CustomText(
            text: widget.title,
            size: 20.r,
            fontWeight: Fonts.semiBold,
          ),
          BlocListener<NotificationsBloc, NotificationsState>(
            listener: (context, state) {
              if (state is NotificationsLoaded) {
                if (state.notifications.isNotEmpty) {
                  setState(() {
                    areNotificationsLoaded = true;
                    areAnyNotifications = true;
                  });
                } else {
                  setState(() {
                    areNotificationsLoaded = true;
                    areAnyNotifications = false;
                  });
                }
              } else if (state is NotificationsLoading) {
                setState(() {
                  areNotificationsLoaded = false;
                });
              }
            },
            child: Builder(builder: (context) {
              if (areNotificationsLoaded) {
                return TapFadeIcon(
                  iconColor: Theme.of(context).iconTheme.color!,
                  onTap: () {
                    Navigator.of(context).push(FromTopPageRoute(
                        builder: (newContext) => BlocProvider.value(
                              value:
                                  BlocProvider.of<NotificationsBloc>(context),
                              child: const NotificationsPopup(
                                heroTag: "notifications",
                              ),
                            )));
                  },
                  icon: areAnyNotifications
                      ? AppIcons.bell
                      : AppIcons.bellOutline,
                  size: Constants.iconDimension,
                );
              } else {
                return SizedBox(
                  height: Constants.iconDimension,
                  width: Constants.iconDimension,
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
