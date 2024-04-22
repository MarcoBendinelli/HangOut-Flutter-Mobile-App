import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/notifications/notifications_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/my_groups/groups_bloc.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/pages/groups/add_group_popup.dart';
import 'package:hang_out_app/presentation/pages/groups/group_cards.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_tablet_pages.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class GroupsTabletPage extends StatelessWidget {
  final String heroTag = 'add-group-hero';

  const GroupsTabletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentUserId =
        context.select((UserBloc bloc) => bloc.state.user.id);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              GroupsBloc(groupsRepository: context.read<MyGroupsRepository>())
                ..add(LoadGroups(userId: currentUserId)),
        ),
        BlocProvider<NotificationsBloc>(
          create: (context) => NotificationsBloc(
              notificationsRepository: context.read<NotificationsRepository>())
            ..add(LoadNotifications(userId: currentUserId)),
        ),
      ],
      child: SafeArea(
        child: Padding(
          padding: TabletConstants.pagePadding(),
          child: Builder(builder: (context) {
            return Column(
              children: [
                const TopBarTabletPages(),
                Expanded(
                  child: Padding(
                    padding: TabletConstants.tabletInsidePagePadding(),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(),
                            Row(
                              children: [
                                CustomText(
                                  text: "New group",
                                  fontFamily: "Inter",
                                  fontWeight: Fonts.regular,
                                  size: TabletConstants.resizeR(24),
                                ),
                                SizedBox(
                                  width: TabletConstants.resizeW(10),
                                ),
                                TapFadeIcon(
                                  key: const Key("add"),
                                  iconColor: Theme.of(context).iconTheme.color!,
                                  onTap: () {
                                    Navigator.of(context).push(HeroDialogRoute(
                                        builder: (newContext) =>
                                            MultiBlocProvider(
                                              providers: [
                                                BlocProvider.value(
                                                  value: BlocProvider.of<
                                                      GroupsBloc>(context),
                                                ),
                                                BlocProvider(
                                                  create: (context) => MembersBloc(
                                                      eventsRepository:
                                                          context.read<
                                                              MyEventsRepository>(),
                                                      groupsRepository:
                                                          context.read<
                                                              MyGroupsRepository>(),
                                                      userRepository:
                                                          context.read<
                                                              UserRepository>())
                                                    ..add(LoadSelectedUsers(
                                                        idUsers: [
                                                          currentUserId
                                                        ],
                                                        currentUserId:
                                                            currentUserId)),
                                                ),
                                              ],
                                              child: AddGroupPopup(
                                                heroTag: heroTag,
                                              ),
                                            )));
                                  },
                                  icon: AppIcons.plusCircleOutline,
                                  size: TabletConstants.iconDimension(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: TabletConstants.spaceBtwCards(),
                        ),
                        const Expanded(
                          child: GroupCards(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
