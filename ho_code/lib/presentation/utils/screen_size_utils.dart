import 'package:flutter/material.dart';

enum ScreenSize { small, normal, large, extraLarge }

const int tabletShortestSide = 600;

ScreenSize getSize(BuildContext context) {
  double deviceWidth = MediaQuery.of(context).size.shortestSide;
  if (deviceWidth > 900) return ScreenSize.large;
  if (deviceWidth > tabletShortestSide) return ScreenSize.large; // tablet
  if (deviceWidth > 300) return ScreenSize.normal; // iphone
  return ScreenSize.normal;
}

const Size tabletPortraitSize = Size(1024, 1374);
const Size tabletLandscapeSize = Size(1374, 1024);
