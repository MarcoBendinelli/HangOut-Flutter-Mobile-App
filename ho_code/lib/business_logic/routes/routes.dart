import 'package:flutter/widgets.dart';
import 'package:hang_out_app/presentation/login/login_page.dart';
import 'package:hang_out_app/presentation/login/login_tablet_page.dart';
import 'package:hang_out_app/presentation/pages/home_page.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/presentation/pages/home_tablet_page.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.authenticated:
      return [HomePage.page()];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
  }
}

List<Page<dynamic>> onGenerateTabletAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.authenticated:
      return [HomeTabletPage.page()];
    case AppStatus.unauthenticated:
      return [LoginTabletPage.page()];
  }
}
