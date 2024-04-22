// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/repositories/authentication_repository.dart';
import 'package:hang_out_app/presentation/sign_up/sign_up_form.dart';
import 'package:hang_out_app/presentation/sign_up/sign_up_page.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  group('SignUpPage', () {
    test('has a route', () {
      expect(SignUpPage.route(), isA<MaterialPageRoute<void>>());
    });

    testWidgets('renders a SignUpForm', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(builder: (context, child) {
          return RepositoryProvider<AuthenticationRepository>(
            create: (_) => MockAuthenticationRepository(),
            child: MaterialApp(home: SignUpPage()),
          );
        }),
      );
      expect(find.byType(SignUpForm), findsOneWidget);
    });
  });
}
