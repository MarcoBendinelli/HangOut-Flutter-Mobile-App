import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';

class BottomWhiteNavBar extends StatelessWidget {
  final contents = const <String, Icon>{
    "events": Icon(key: Key("go-to-events-page"), AppIcons.calendarOutline),
    "explore": Icon(key: Key("go-to-explore-page"), AppIcons.compassOutline),
    "groups": Icon(key: Key("go-to-groups-page"), AppIcons.peopleOutline),
    "profile": Icon(key: Key("go-to-profile-page"), AppIcons.personOutline),
  };

  final activeContents = const <String, Icon>{
    "events": Icon(AppIcons.calendar),
    "explore": Icon(AppIcons.compass),
    "groups": Icon(AppIcons.people),
    "profile": Icon(AppIcons.person),
  };

  final Function(int) _onTap;
  final int _selectedIndex;

  const BottomWhiteNavBar(this._selectedIndex, this._onTap, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedFontSize: 0.0,
      unselectedFontSize: 0.0,
      currentIndex: _selectedIndex,
      onTap: _onTap,
      iconSize: Constants.iconDimension,
      items: [
        for (String label in contents.keys)
          BottomNavigationBarItem(
              icon: contents[label]!,
              label: label,
              tooltip: '',
              activeIcon: activeContents[label]!),
      ],
    );
  }
}
