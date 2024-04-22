import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/repositories/authentication_repository.dart';
import 'package:hang_out_app/presentation/login/login_form.dart';
import 'package:hang_out_app/presentation/login/login_page.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  group('LoginPage', () {
    test('has a page', () {
      expect(LoginPage.page(), isA<MaterialPage<void>>());
    });

    testWidgets('renders a LoginForm', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          builder: (context, child) {
            return RepositoryProvider<AuthenticationRepository>(
              create: (_) => MockAuthenticationRepository(),
              child: const MaterialApp(home: LoginPage()),
            );
          },
        ),
      );
      expect(find.byType(LoginForm), findsOneWidget);
    });
  });
}
