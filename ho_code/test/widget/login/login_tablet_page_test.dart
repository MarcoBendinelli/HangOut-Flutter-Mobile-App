import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/repositories/authentication_repository.dart';
// import 'package:hang_out_app/presentation/login/login_page.dart';
import 'package:hang_out_app/presentation/login/login_tablet_form.dart';
import 'package:hang_out_app/presentation/login/login_tablet_page.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  const Size tabletLandscapeSize = Size(1374, 1024);
  group('LoginPage', () {
    test('has a page', () {
      expect(LoginTabletPage.page(), isA<MaterialPage<void>>());
    });

    testWidgets('renders a LoginForm', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
              size: tabletLandscapeSize, devicePixelRatio: 1.0),
          child: ScreenUtilInit(
            builder: (context, child) {
              TabletConstants.setDimensions(context);
              PopupTabletConstants.setSmallestDimension(context);
              return RepositoryProvider<AuthenticationRepository>(
                create: (_) => MockAuthenticationRepository(),
                child: const MaterialApp(home: LoginTabletPage()),
              );
            },
          ),
        ),
      );
      expect(find.byType(LoginTabletForm), findsOneWidget);
    });
  });
}
