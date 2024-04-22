// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/repositories/authentication_repository.dart';
import 'package:hang_out_app/presentation/sign_up/sign_up_tablet_form.dart';
import 'package:hang_out_app/presentation/sign_up/sign_up_tablet_page.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  const Size tabletLandscapeSize = Size(1374, 1024);
  group('SignUpPage', () {
    test('has a route', () {
      expect(SignUpTabletPage.route(), isA<MaterialPageRoute<void>>());
    });

    testWidgets('renders a SignUpForm', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
              size: tabletLandscapeSize, devicePixelRatio: 1.0),
          child: ScreenUtilInit(builder: (context, child) {
            TabletConstants.setDimensions(context);
            PopupTabletConstants.setSmallestDimension(context);
            return RepositoryProvider<AuthenticationRepository>(
              create: (_) => MockAuthenticationRepository(),
              child: MaterialApp(home: SignUpTabletPage()),
            );
          }),
        ),
      );
      expect(find.byType(SignUpTabletForm), findsOneWidget);
    });
  });
}
