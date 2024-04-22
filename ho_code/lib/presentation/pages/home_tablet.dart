import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/user/modify_user_cubit.dart';
import 'package:hang_out_app/presentation/pages/events/events_tablet_page.dart';
import 'package:hang_out_app/presentation/pages/explore/explore_tablet_page.dart';
import 'package:hang_out_app/presentation/pages/groups/groups_tablet_page.dart';
import 'package:hang_out_app/presentation/pages/profile/profile_tablet_page.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/bars/bottom_tablet_nav_bar.dart';

class HomeTablet extends StatefulWidget {
  static String id = 'home_page_screen';

  const HomeTablet({super.key});

  @override
  State<HomeTablet> createState() => _HomeTabletState();

  static Page<void> page() => const MaterialPage<void>(child: HomeTablet());
}

class _HomeTabletState extends State<HomeTablet> {
  int _selectedIndex = 1;

  void onTapNav(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List pages = [
    const EventsTabletPage(),
    const ExploreTabletPage(interests: []),
    const GroupsTabletPage(),
    const ProfileTabletPage(),
  ];

  @override
  Widget build(BuildContext context) {
    List<String> interests =
        context.select((UserBloc bloc) => bloc.state.user.interests);
    pages[1] = ExploreTabletPage(interests: interests);

    return OrientationBuilder(builder: (context, orientation) {
      TabletConstants.setOrientation(MediaQuery.of(context).orientation);
      return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Theme.of(context).brightness == Brightness.light
                    ? const AssetImage(TabletConstants.tabletBgMain)
                    : const AssetImage(TabletConstants.tabletDarkBgMain),
                fit: BoxFit.cover,
              ),
            ),
            child: BlocListener<ModifyUserCubit, ModifyUserState>(
              listener: (context, state) {
                if (state.status == ModifyUserStatus.success) {
                  interests = state.userUpdated.interests;
                }
                pages[1] = ExploreTabletPage(interests: interests);
              },
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: pages[_selectedIndex],
                bottomNavigationBar: BottomTabletNavBar(
                  _selectedIndex,
                  onTapNav,
                ),
              ),
            ),
          ));
    });
  }
}
