import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_groups_events.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/my_groups/groups_bloc.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/pages/groups/add_group_popup.dart';
import 'package:hang_out_app/presentation/pages/groups/group_cards.dart';

class GroupsPage extends StatelessWidget {
  final String heroTag = 'add-group-hero';

  const GroupsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentUserId =
        context.select((UserBloc bloc) => bloc.state.user.id);
    return BlocProvider(
      create: (context) =>
          GroupsBloc(groupsRepository: context.read<MyGroupsRepository>())
            ..add(LoadGroups(userId: currentUserId)),
      child: SafeArea(
        child: Padding(
          padding: Constants.pagePadding,
          child: Builder(builder: (context) {
            return Column(
              children: [
                TopBarGroupsEventsPages(
                  title: "My Groups",
                  onAddPress: () async {
                    Navigator.of(context).push(HeroDialogRoute(
                        builder: (newContext) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(
                                  value: BlocProvider.of<GroupsBloc>(context),
                                ),
                                BlocProvider(
                                  create: (context) => MembersBloc(
                                      eventsRepository:
                                          context.read<MyEventsRepository>(),
                                      groupsRepository:
                                          context.read<MyGroupsRepository>(),
                                      userRepository:
                                          context.read<UserRepository>())
                                    ..add(LoadSelectedUsers(
                                        idUsers: [currentUserId],
                                        currentUserId: currentUserId)),
                                ),
                              ],
                              child: AddGroupPopup(
                                heroTag: heroTag,
                              ),
                            )));
                  },
                ),
                SizedBox(
                  height: Constants.spaceBtwCards.h,
                ),
                const Expanded(
                  child: GroupCards(),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
