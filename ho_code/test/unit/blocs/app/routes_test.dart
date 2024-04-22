import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/routes/routes.dart';
import 'package:hang_out_app/presentation/login/login_page.dart';
import 'package:hang_out_app/presentation/login/login_tablet_page.dart';
import 'package:hang_out_app/presentation/pages/home_page.dart';
import 'package:hang_out_app/presentation/pages/home_tablet_page.dart';

void main() {
  group('onGenerateAppViewPages', () {
    test('returns [HomePage] when authenticated', () {
      expect(
        onGenerateAppViewPages(AppStatus.authenticated, []),
        [
          isA<MaterialPage<void>>().having(
            (p) => p.child,
            'child',
            isA<HomePage>(),
          )
        ],
      );
    });

    test('returns [LoginPage] when unauthenticated', () {
      expect(
        onGenerateAppViewPages(AppStatus.unauthenticated, []),
        [
          isA<MaterialPage<void>>().having(
            (p) => p.child,
            'child',
            isA<LoginPage>(),
          )
        ],
      );
    });
  });
  group('onGenerateTabletAppViewPages', () {
    test('returns [HomeTabletPage] when authenticated', () {
      expect(
        onGenerateTabletAppViewPages(AppStatus.authenticated, []),
        [
          isA<MaterialPage<void>>().having(
            (p) => p.child,
            'child',
            isA<HomeTabletPage>(),
          )
        ],
      );
    });

    test('returns [LoginPage] when unauthenticated', () {
      expect(
        onGenerateTabletAppViewPages(AppStatus.unauthenticated, []),
        [
          isA<MaterialPage<void>>().having(
            (p) => p.child,
            'child',
            isA<LoginTabletPage>(),
          )
        ],
      );
    });
  });
}
