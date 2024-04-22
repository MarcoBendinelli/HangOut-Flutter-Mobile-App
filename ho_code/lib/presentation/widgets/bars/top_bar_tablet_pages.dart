import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/notifications/notifications_bloc.dart';
import 'package:hang_out_app/presentation/utils/animations/from_top_page_route.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/popups/notifications/notifications_popup.dart';

class TopBarTabletPages extends StatefulWidget {
  const TopBarTabletPages({super.key});

  @override
  State<TopBarTabletPages> createState() => _TopBarTabletPagesState();
}

class _TopBarTabletPagesState extends State<TopBarTabletPages> {
  bool areAnyNotifications = false;
  bool areTheyLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: "HangOut",
          size: TabletConstants.hangOutTextDimension(),
          fontFamily: "Inter",
          fontWeight: Fonts.bold,
        ),
        BlocListener<NotificationsBloc, NotificationsState>(
          listener: (context, state) {
            if (state is NotificationsLoaded) {
              if (state.notifications.isNotEmpty) {
                setState(() {
                  areTheyLoaded = true;
                  areAnyNotifications = true;
                });
              } else {
                setState(() {
                  areTheyLoaded = true;
                  areAnyNotifications = false;
                });
              }
            } else if (state is NotificationsLoading) {
              setState(() {
                areTheyLoaded = false;
              });
            }
          },
          child: Builder(builder: (context) {
            if (areTheyLoaded) {
              return TapFadeIcon(
                iconColor: Theme.of(context).iconTheme.color!,
                onTap: () {
                  Navigator.of(context).push(FromTopPageRoute(
                      builder: (newContext) => BlocProvider.value(
                            value: BlocProvider.of<NotificationsBloc>(context),
                            child: const NotificationsPopup(
                              heroTag: "notifications",
                            ),
                          )));
                },
                icon:
                    areAnyNotifications ? AppIcons.bell : AppIcons.bellOutline,
                size: TabletConstants.iconDimension(),
              );
            } else {
              return SizedBox(
                height: TabletConstants.iconDimension(),
                width: TabletConstants.iconDimension(),
              );
            }
          }),
        ),
      ],
    );
  }
}
