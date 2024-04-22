import 'package:flutter/material.dart';
import 'colors.dart';

final myTheme = ThemeData(
  cardColor: AppColors.whiteColor,
  dividerColor: AppColors.almostBlackColor,

  /// Used when category is clicked for border color (in general selected border in card)
  primaryColor: AppColors.blackColor,

  /// Set to trasparent to avoid that the buttons on pressed become black
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,

  /// Used whenever there is the need of a gray color (hint text, border, ...)
  hintColor: Colors.black26,

  // primary=what goes on card color
  // primaryColor: AppColors.almostBlackColor,

  colorScheme: const ColorScheme.light(
      error: Color.fromARGB(255, 255, 137, 165),
      /// Used in chat for bottom part
      secondary: AppColors.almostBlackColor,
      onSecondary: AppColors.whiteColor),

  iconTheme: const IconThemeData(color: AppColors.almostBlackColor),

  textSelectionTheme: const TextSelectionThemeData(
    /// Cursor of text field (needs to be changed in dark theme or it will default to black)
    cursorColor: AppColors.almostBlackColor,
  ),

  /// Chat app bar
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.whiteColor,
    titleTextStyle: TextStyle(color: AppColors.almostBlackColor),
    iconTheme: IconThemeData(color: AppColors.almostBlackColor),
    toolbarHeight: 90,
  ),

  /// Bottom nav bar
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    backgroundColor: AppColors.whiteColor,
    selectedItemColor: AppColors.almostBlackColor,
    unselectedItemColor: AppColors.almostBlackColor,
    showSelectedLabels: false,
    showUnselectedLabels: false,
    enableFeedback: false,
  ),
);

// final myTheme = ThemeData(
//   primaryColor: AppColors.almostBlackColor,
//   cardColor: AppColors.whiteColor,
//   hintColor: Colors.black54,
//   splashColor: Colors.transparent,
//   highlightColor: Colors.transparent,
// bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//   type: BottomNavigationBarType.fixed,
//   backgroundColor: AppColors.whiteColor,
//   selectedItemColor: AppColors.almostBlackColor,
//   unselectedItemColor: AppColors.almostBlackColor,
//   showSelectedLabels: false,
//   showUnselectedLabels: false,
//   enableFeedback: false,
// ),
// appBarTheme: const AppBarTheme(
//   backgroundColor: AppColors.whiteColor,
//   titleTextStyle: TextStyle(color: AppColors.almostBlackColor),
//   iconTheme: IconThemeData(color: AppColors.almostBlackColor),
//   toolbarHeight: 90,
// ),
//   iconTheme: const IconThemeData(color: AppColors.almostBlackColor),
// );
