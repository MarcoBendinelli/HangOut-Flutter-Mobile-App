import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/pages/profile/profile_page.dart';
import 'package:hang_out_app/presentation/pages/events/events_page.dart';
import 'package:hang_out_app/presentation/pages/explore/explore_page.dart';
import 'package:hang_out_app/presentation/pages/groups/groups_page.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/widgets/bars/bottom_white_nav_bar.dart';

class Home extends StatefulWidget {
  static String id = 'home_page_screen';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();

  static Page<void> page() => const MaterialPage<void>(child: Home());
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;

  List pages = [
    const EventsPage(),
    const ExplorePage(),
    const GroupsPage(),
    const ProfilePage(),
  ];

  void onTapNav(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Theme.of(context).brightness == Brightness.light
                ? const AssetImage(Constants.phoneBgMain)
                : const AssetImage(Constants.phoneDarkBgMain),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: pages[_selectedIndex],
          bottomNavigationBar: BottomWhiteNavBar(
            _selectedIndex,
            onTapNav,
          ),
        ),
      ),
    );
  }
}
