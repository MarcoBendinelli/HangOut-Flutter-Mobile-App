import 'package:flutter/material.dart';
import 'colors.dart';

final myDarkTheme = ThemeData(
  cardColor: AppColors.almostBlackColor,
  dividerColor: AppColors.whiteColor,

  /// Used when category is clicked for border color (in general selected border in card)
  primaryColor: AppColors.whiteColor,
  
  /// Set to trasparent to avoid that the buttons on pressed become black
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
  colorScheme: const ColorScheme.dark(
      error: Color.fromARGB(255, 255, 137, 165),

      ///used in chat for bottom part
      secondary: AppColors.blackColor,
      onSecondary: AppColors.whiteColor),
  iconTheme: const IconThemeData(color: AppColors.whiteColor),
  textSelectionTheme: const TextSelectionThemeData(
    ///cursor of textfield (needs to be changed in darktheme or it will default to black)
    cursorColor: AppColors.whiteColor,
  ),

  ///chat app bar
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.almostBlackColor,
    titleTextStyle: TextStyle(color: AppColors.whiteColor),
    iconTheme: IconThemeData(color: AppColors.whiteColor),
    toolbarHeight: 90,
  ),

  ///bottom nav bar
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    backgroundColor: AppColors.almostBlackColor,
    selectedItemColor: AppColors.whiteColor,
    unselectedItemColor: AppColors.whiteColor,
    showSelectedLabels: false,
    showUnselectedLabels: false,
    enableFeedback: false,
  ),
);
