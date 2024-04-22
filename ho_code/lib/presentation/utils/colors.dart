import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:flutter/material.dart';

class AppColors {
  //static const Color textColor = Color(0xFFccc7c5);
  static const Color almostBlackColor = Color.fromARGB(255, 28, 33, 41);
  static const Color blackColor = Color.fromARGB(255, 0, 0, 0);
  static const Color whiteColor = Color.fromARGB(255, 255, 255, 255);
  static const Color greenColor = Color.fromARGB(255, 28, 194, 111);
  static const Color grayColor = Color.fromARGB(255, 227, 227, 227);
  static const Color transparentText = Color.fromARGB(255, 140, 133, 133);
  static const Color googleSignInColor = Color.fromARGB(255, 38, 45, 51);
  static const Color twitterSignInColor = Color.fromARGB(255, 0, 172, 238);
  static const Color transparentLogin = Color.fromARGB(25, 0, 0, 0);
  static const Color error = Color.fromARGB(187, 191, 9, 9);
}

class CategoryColors {
  static const Color food = Color.fromARGB(255, 255, 231, 144);
  static const Color sport = Color.fromARGB(255, 144, 182, 255);
  static const Color culture = Color.fromARGB(255, 255, 144, 178);
  static const Color music = Color.fromARGB(255, 255, 180, 243);
  static const Color nature = Color.fromARGB(255, 225, 234, 119);
  static const Color game = Color.fromARGB(255, 153, 144, 255);
  static const Color study = Color.fromARGB(255, 255, 164, 144);
  static const Color show = Color.fromARGB(255, 255, 132, 228);
  static const Color shopping = Color.fromARGB(255, 173, 248, 161);
  static const Color travel = Color.fromARGB(255, 180, 228, 255);
  static const Color drink = Color.fromARGB(255, 255, 144, 144);
  static const Color party = Color.fromARGB(255, 199, 161, 248);
  static const Color other = Color.fromARGB(255, 28, 33, 41);

  static const Color otherFilter = Color.fromARGB(255, 228, 228, 228);

  static const Map<String, Color> mapper = {
    'food': food,
    'sport': sport,
    'culture': culture,
    'music': music,
    'nature': nature,
    'game': game,
    'study': study,
    'show': show,
    'shopping': shopping,
    'travel': travel,
    'drink': drink,
    'party': party,
    'other': other,
  };

  ///Return the color of the category given the name or the default if the name is not present
  static Color getColor(String key) {
    return mapper[key] ?? other;
  }
}

class CategoryIcons {
  static const Map<String, IconData> mapper = {
    'food': AppIcons.food,
    'sport': AppIcons.sport,
    'culture': AppIcons.culture,
    'music': AppIcons.music,
    'nature': AppIcons.nature,
    'game': AppIcons.game,
    'study': AppIcons.study,
    'show': AppIcons.show,
    'shopping': AppIcons.shopping,
    'travel': AppIcons.travel,
    'drink': AppIcons.drink,
    'party': AppIcons.party,
    'other': AppIcons.other,
  };
}
