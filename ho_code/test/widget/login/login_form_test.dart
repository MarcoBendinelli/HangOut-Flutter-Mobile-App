import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:hang_out_app/business_logic/cubits/login/login_cubit.dart';
import 'package:hang_out_app/business_logic/form_inputs/email.dart';
import 'package:hang_out_app/business_logic/form_inputs/password.dart';
import 'package:hang_out_app/data/repositories/authentication_repository.dart';
import 'package:hang_out_app/presentation/login/login_form.dart';
import 'package:hang_out_app/presentation/sign_up/sign_up_page.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

class MockEmail extends Mock implements Email {}

class MockPassword extends Mock implements Password {}

void main() {
  const loginButtonKey = Key('loginForm_continue_raisedButton');
  const signInWithGoogleButtonKey = Key('loginForm_googleLogin_raisedButton');
  const emailInputKey = Key('loginForm_emailInput_textField');
  const passwordInputKey = Key('loginForm_passwordInput_textField');
  const createAccountButtonKey = Key('loginForm_createAccount_flatButton');

  const testEmail = 'test@gmail.com';
  const testPassword = 'testP@ssw0rd1';

  group('LoginForm', () {
    late LoginCubit loginCubit;

    setUp(() {
      loginCubit = MockLoginCubit();
      when(() => loginCubit.state).thenReturn(const LoginState());
      when(() => loginCubit.logInWithGoogle()).thenAnswer((_) async {});
      when(() => loginCubit.logInWithCredentials()).thenAnswer((_) async {});
    });

    group('calls', () {
      testWidgets('emailChanged when email changes', (tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: loginCubit,
                    child: const LoginForm(),
                  ),
                ),
              );
            },
          ),
        );
        await tester.enterText(find.byKey(emailInputKey), testEmail);
        verify(() => loginCubit.emailChanged(testEmail)).called(1);
      });

      testWidgets('passwordChanged when password changes', (tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: loginCubit,
                    child: const LoginForm(),
                  ),
                ),
              );
            },
          ),
        );
        await tester.enterText(find.byKey(passwordInputKey), testPassword);
        verify(() => loginCubit.passwordChanged(testPassword)).called(1);
      });

      // testWidgets('logInWithCredentials when login button is pressed',
      //     (tester) async {
      //   when(() => loginCubit.state).thenReturn(
      //     const LoginState(status: FormzStatus.valid),
      //   );
      //   await tester.pumpWidget(
      //     ScreenUtilInit(
      //       builder: (context, child) {
      //         return MaterialApp(
      //           home: Scaffold(
      //             body: BlocProvider.value(
      //               value: loginCubit,
      //               child: const LoginForm(),
      //             ),
      //           ),
      //         );
      //       },
      //     ),
      //   );

      //   await tester.tap(find.byKey(loginButtonKey));
      //   verify(() => loginCubit.logInWithCredentials()).called(1);
      // });

      testWidgets('logInWithGoogle when sign in with google button is pressed',
          (tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: loginCubit,
                    child: const LoginForm(),
                  ),
                ),
              );
            },
          ),
        );
        await tester.tap(find.byKey(signInWithGoogleButtonKey));
        verify(() => loginCubit.logInWithGoogle()).called(1);
      });
    });

    group('renders', () {
      testWidgets('AuthenticationFailure SnackBar when submission fails',
          (tester) async {
        whenListen(
          loginCubit,
          Stream.fromIterable(const <LoginState>[
            LoginState(status: FormzStatus.submissionInProgress),
            LoginState(status: FormzStatus.submissionFailure),
          ]),
        );
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: loginCubit,
                    child: const LoginForm(),
                  ),
                ),
              );
            },
          ),
        );
        await tester.pump();
        expect(find.text('Authentication Failure'), findsOneWidget);
      });

      testWidgets('invalid email error text when email is invalid',
          (tester) async {
        final email = MockEmail();
        when(() => email.invalid).thenReturn(true);
        when(() => loginCubit.state).thenReturn(LoginState(email: email));
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: loginCubit,
                    child: const LoginForm(),
                  ),
                ),
              );
            },
          ),
        );
        expect(find.text('invalid email'), findsOneWidget);
      });

      testWidgets('invalid password error text when password is invalid',
          (tester) async {
        final password = MockPassword();
        when(() => password.invalid).thenReturn(true);
        when(() => loginCubit.state).thenReturn(LoginState(password: password));
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: loginCubit,
                    child: const LoginForm(),
                  ),
                ),
              );
            },
          ),
        );
        expect(find.text('invalid password'), findsOneWidget);
      });

      testWidgets('disabled login button when status is not validated',
          (tester) async {
        when(() => loginCubit.state).thenReturn(
          const LoginState(status: FormzStatus.invalid),
        );
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: loginCubit,
                    child: const LoginForm(),
                  ),
                ),
              );
            },
          ),
        );
        final loginButton = tester.widget<ElevatedButton>(
          find.byKey(loginButtonKey),
        );
        expect(loginButton.enabled, isFalse);
      });

      testWidgets('enabled login button when status is validated',
          (tester) async {
        when(() => loginCubit.state).thenReturn(
          const LoginState(status: FormzStatus.valid),
        );
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: loginCubit,
                    child: const LoginForm(),
                  ),
                ),
              );
            },
          ),
        );
        final loginButton = tester.widget<ElevatedButton>(
          find.byKey(loginButtonKey),
        );
        expect(loginButton.enabled, isTrue);
      });

      testWidgets('Sign in with Google Button', (tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: loginCubit,
                    child: const LoginForm(),
                  ),
                ),
              );
            },
          ),
        );
        expect(find.byKey(signInWithGoogleButtonKey), findsOneWidget);
      });
    });

    group('navigates', () {
      testWidgets('to SignUpPage when Create Account is pressed',
          (tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return RepositoryProvider<AuthenticationRepository>(
                create: (_) => MockAuthenticationRepository(),
                child: MaterialApp(
                  home: Scaffold(
                    body: BlocProvider.value(
                      value: loginCubit,
                      child: const LoginForm(),
                    ),
                  ),
                ),
              );
            },
          ),
        );
        await tester.tap(find.byKey(createAccountButtonKey));
        await tester.pumpAndSettle();
        expect(find.byType(SignUpPage), findsOneWidget);
      });
      testWidgets('unfocus', (tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return RepositoryProvider<AuthenticationRepository>(
                create: (_) => MockAuthenticationRepository(),
                child: MaterialApp(
                  home: Scaffold(
                    body: BlocProvider.value(
                      value: loginCubit,
                      child: const LoginForm(),
                    ),
                  ),
                ),
              );
            },
          ),
        );
        expect(find.byType(LoginForm), findsOneWidget);
        await tester.tap(find.byType(SingleChildScrollView));
        await tester.pumpAndSettle();
        expect(find.byType(LoginForm), findsOneWidget);
      });
    });
  });
}
