import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';

import '../../utils/constants.dart';

class BottomBlackNavBar extends StatelessWidget {
  final contents = const <String, Icon>{
    "events": Icon(AppIcons.calendarOutline),
    "explore": Icon(AppIcons.compassOutline),
    "groups": Icon(AppIcons.peopleOutline),
    "profile": Icon(AppIcons.personOutline),
  };

  final activeContents = const <String, Icon>{
    "events": Icon(AppIcons.calendar),
    "explore": Icon(AppIcons.compass),
    "groups": Icon(AppIcons.people),
    "profile": Icon(AppIcons.person),
  };

  final Function(int) _onTap;
  final int _selectedIndex;

  const BottomBlackNavBar(this._selectedIndex, this._onTap, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(40),
        ),
        child: SizedBox(
          height: 50,
          child: BottomNavigationBar(
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
          ),
        ),
      ),
    );
  }
}
