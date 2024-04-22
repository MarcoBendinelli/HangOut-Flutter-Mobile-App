import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/presentation/pages/home.dart';
import 'package:hang_out_app/presentation/widgets/chat/chat_view.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_event_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_group_popup.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';

class HomePage extends StatelessWidget {
  static String id = 'home_page_screen';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    String currentUserId = context.select((AppBloc bloc) => bloc.state.user.id);
    BlocProvider.of<UserBloc>(context).add(LoadUser(userId: currentUserId));

    /* Home is a different widget so the rebuilding from changing pages with navbar
    does not re call the LoadUser above this comment*/
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoaded) {
          BlocProvider.of<UserBloc>(context)
              .initializeNotification(currentUserId: currentUserId);

          BlocProvider.of<UserBloc>(context).setOnClickNotifications(
              onClickPublicGroupNotification: (String id) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).push(
              HeroDialogRoute(
                builder: (BuildContext context) => SingleGroupPopup(
                  heroTag: "GroupPopup",
                  groupId: id,
                  fromExplore: true,
                  fromNotification: true,
                ),
              ),
            );
          }, onClickGroupNotification: (String id) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).push(
              HeroDialogRoute(
                builder: (BuildContext context) =>
                    SingleGroupPopup(heroTag: "GroupPopup", groupId: id),
              ),
            );
          }, onClickEventNotification: (String id) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).push(HeroDialogRoute(
                builder: (BuildContext context) => SingleEventPopup(
                      heroTag: "EventPopup",
                      eventId: id,
                      fromNotification: true,
                      fromExplore: true,
                    )));
          }, onClickChatGroupNotification: (String id, String thingToJoinName) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.push(
                context,
                CupertinoPageRoute<bool>(
                    builder: (_) => ChatView(
                          id: id,
                          isForTheGroup: true,
                          chatName: thingToJoinName,
                        )));
          }, onClickChatEventNotification: (String id, String thingToJoinName) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.push(
                context,
                CupertinoPageRoute<bool>(
                    builder: (_) => ChatView(
                          id: id,
                          isForTheGroup: false,
                          chatName: thingToJoinName,
                        )));
          });

          return const Home();
        } else if (state is UserLoading) {
          return const OurCircularProgressIndicator();
        } else {
          return Container();
        }
      },
    );
  }

  static Page<void> page() => const MaterialPage<void>(child: HomePage());
}
