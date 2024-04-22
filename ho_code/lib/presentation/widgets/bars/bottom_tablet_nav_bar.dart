import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class BottomTabletNavBar extends StatelessWidget {
  final contents = const <String, Icon>{
    "My events": Icon(key: Key("go-to-events-page"), AppIcons.calendarOutline),
    "Explore": Icon(key: Key("go-to-explore-page"), AppIcons.compassOutline),
    "My groups": Icon(key: Key("go-to-groups-page"), AppIcons.peopleOutline),
    "My profile": Icon(key: Key("go-to-profile-page"), AppIcons.personOutline),
  };

  final activeContents = const <String, Icon>{
    "My events": Icon(AppIcons.calendar),
    "Explore": Icon(AppIcons.compass),
    "My groups": Icon(AppIcons.people),
    "My profile": Icon(AppIcons.person),
  };

  final Function(int) _onTap;
  final int _selectedIndex;

  const BottomTabletNavBar(this._selectedIndex, this._onTap, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // backgroundColor: Colors.transparent,
      elevation: 0.0,
      currentIndex: _selectedIndex,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: _onTap,
      iconSize: TabletConstants.iconDimension(),
      landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
      items: [
        for (String label in contents.keys)
          BottomNavigationBarItem(
              icon: SizedBox(
                width: TabletConstants.resizeW(245),
                child: Wrap(
                  children: [
                    SizedBox(
                      width: TabletConstants.resizeW(80),
                    ),
                    contents[label]!,
                    SizedBox(
                      width: TabletConstants.resizeW(10),
                    ),
                    SizedBox(
                      width: TabletConstants.resizeW(85),
                    ),
                  ],
                ),
              ),
              label: label,
              tooltip: '',
              activeIcon: SizedBox(
                width: TabletConstants.resizeW(245),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: TabletConstants.resizeW(80),
                    ),
                    activeContents[label]!,
                    SizedBox(
                      width: TabletConstants.resizeW(10),
                    ),
                    SizedBox(
                      width: TabletConstants.resizeW(85),
                      child: CustomText(
                          text: label,
                          fontFamily: 'Inter',
                          fontWeight: Fonts.bold,
                          size: TabletConstants.resizeR(16)),
                    )
                  ],
                ),
              )),
      ],
    );
  }
}
