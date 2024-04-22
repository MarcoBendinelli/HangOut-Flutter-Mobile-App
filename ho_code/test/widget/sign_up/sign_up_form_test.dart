import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:formz/formz.dart';
import 'package:hang_out_app/business_logic/cubits/sign_up/sign_up_cubit.dart';
import 'package:hang_out_app/business_logic/form_inputs/confirmed_password.dart';
import 'package:hang_out_app/business_logic/form_inputs/email.dart';
import 'package:hang_out_app/business_logic/form_inputs/name.dart';
import 'package:hang_out_app/business_logic/form_inputs/password.dart';
import 'package:hang_out_app/data/repositories/authentication_repository.dart';
import 'package:hang_out_app/presentation/sign_up/sign_up_form.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockSignUpCubit extends MockCubit<SignUpState> implements SignUpCubit {}

class MockEmail extends Mock implements Email {}

class MockName extends Mock implements Name {}

class MockPassword extends Mock implements Password {}

class MockConfirmedPassword extends Mock implements ConfirmedPassword {}

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  const signUpButtonKey = Key('signUpForm_continue_raisedButton');
  const emailInputKey = Key('signUpForm_emailInput_textField');
  const nameInputKey = Key('signUpForm_nameInput_textField');
  const photoInputKey = Key('signUpForm_photoInput_button');

  const passwordInputKey = Key('signUpForm_passwordInput_textField');
  const confirmedPasswordInputKey =
      Key('signUpForm_confirmedPasswordInput_textField');

  const testEmail = 'test@gmail.com';
  const testPassword = 'testP@ssw0rd1';
  const testConfirmedPassword = 'testP@ssw0rd1';
  const testName = "Pippo";
  final image = XFile("test_resources/example.jpg");

  group('SignUpForm', () {
    late SignUpCubit signUpCubit;
    late MockImagePicker mockImagePicker;

    setUp(() {
      mockImagePicker = MockImagePicker();
      signUpCubit = MockSignUpCubit();
      when(() => signUpCubit.state).thenReturn(const SignUpState());
      when(() => signUpCubit.signUpFormSubmitted()).thenAnswer((_) async {});
      when(() => mockImagePicker.pickImage(
            source: ImageSource.gallery,
          )).thenAnswer((_) async => image);
    });

    group('calls', () {
      testWidgets('emailChanged when email changes', (tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        await tester.enterText(find.byKey(emailInputKey), testEmail);
        verify(() => signUpCubit.emailChanged(testEmail)).called(1);
      });

      testWidgets('nameChanged when name changes', (tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        await tester.enterText(find.byKey(nameInputKey), testName);
        verify(() => signUpCubit.nameChanged(testName)).called(1);
      });

      testWidgets('photoChanged when photo changes', (tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: PhotoInput(
                      imagePicker: mockImagePicker,
                    ),
                  ),
                ),
              );
            },
          ),
        );
        await tester.tap(
          find.byKey(photoInputKey),
        );
        verify(() => signUpCubit.photoChanged(image)).called(1);
      });

      testWidgets('passwordChanged when password changes', (tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        await tester.enterText(find.byKey(passwordInputKey), testPassword);
        verify(() => signUpCubit.passwordChanged(testPassword)).called(1);
      });

      testWidgets('confirmedPasswordChanged when confirmedPassword changes',
          (tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        await tester.enterText(
          find.byKey(confirmedPasswordInputKey),
          testConfirmedPassword,
        );
        verify(
          () => signUpCubit.confirmedPasswordChanged(testConfirmedPassword),
        ).called(1);
      });

      // testWidgets('signUpFormSubmitted when sign up button is pressed',
      //     (tester) async {
      //   when(() => signUpCubit.state).thenReturn(
      //     const SignUpState(status: FormzStatus.valid),
      //   );
      //   await tester.pumpWidget(
      //     ScreenUtilInit(
      //       builder: (context, child) {
      //         return MaterialApp(
      //           home: Scaffold(
      //             body: BlocProvider.value(
      //               value: signUpCubit,
      //               child: const SignUpForm(),
      //             ),
      //           ),
      //         );
      //       },
      //     ),
      //   );
      //   await tester.pumpAndSettle();
      //   expect(find.byKey(signUpButtonKey), findsOneWidget);
      //   await tester.tap(find.byKey(signUpButtonKey));
      //   await tester.pumpAndSettle();
      //   verify(() => signUpCubit.signUpFormSubmitted()).called(1);
      // });
    });

    group('renders', () {
      testWidgets('Sign Up Failure SnackBar when submission fails',
          (tester) async {
        whenListen(
          signUpCubit,
          Stream.fromIterable(const <SignUpState>[
            SignUpState(status: FormzStatus.submissionInProgress),
            SignUpState(status: FormzStatus.submissionFailure),
          ]),
        );
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        await tester.pump();
        expect(find.text('Sign Up Failure'), findsOneWidget);
      });

      testWidgets('invalid email error text when email is invalid',
          (tester) async {
        final email = MockEmail();
        when(() => email.invalid).thenReturn(true);
        when(() => signUpCubit.state).thenReturn(SignUpState(email: email));
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        expect(find.text('invalid email'), findsOneWidget);
      });

      testWidgets('renders photo if loaded', (tester) async {
        when(() => signUpCubit.state).thenReturn(SignUpState(photo: image));
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        expect(find.byIcon(AppIcons.cameraOutline), findsNothing);
      });

      testWidgets('invalid name error text when name is invalid',
          (tester) async {
        final name = MockName();
        when(() => name.invalid).thenReturn(true);
        when(() => signUpCubit.state).thenReturn(SignUpState(name: name));
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        expect(find.text('invalid name (must start with capital letter)'),
            findsOneWidget);
      });

      testWidgets('invalid password error text when password is invalid',
          (tester) async {
        final password = MockPassword();
        when(() => password.invalid).thenReturn(true);
        when(() => signUpCubit.state)
            .thenReturn(SignUpState(password: password));
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        expect(find.text('invalid password'), findsOneWidget);
      });

      testWidgets(
          'invalid confirmedPassword error text'
          ' when confirmedPassword is invalid', (tester) async {
        final confirmedPassword = MockConfirmedPassword();
        when(() => confirmedPassword.invalid).thenReturn(true);
        when(() => signUpCubit.state)
            .thenReturn(SignUpState(confirmedPassword: confirmedPassword));
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        expect(find.text('no match'), findsOneWidget);
      });

      testWidgets('disabled sign up button when status is not validated',
          (tester) async {
        when(() => signUpCubit.state).thenReturn(
          const SignUpState(status: FormzStatus.invalid),
        );
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        final signUpButton = tester.widget<ElevatedButton>(
          find.byKey(signUpButtonKey),
        );
        expect(signUpButton.enabled, isFalse);
      });

      testWidgets('enabled sign up button when status is validated',
          (tester) async {
        when(() => signUpCubit.state).thenReturn(
          const SignUpState(status: FormzStatus.valid),
        );
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        final signUpButton = tester.widget<ElevatedButton>(
          find.byKey(signUpButtonKey),
        );
        expect(signUpButton.enabled, isTrue);
      });
    });

    group('navigates', () {
      testWidgets('back to previous page when submission status is success',
          (tester) async {
        whenListen(
          signUpCubit,
          Stream.fromIterable(const <SignUpState>[
            SignUpState(status: FormzStatus.submissionInProgress),
            SignUpState(status: FormzStatus.submissionSuccess),
          ]),
        );
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        expect(find.byType(SignUpForm), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byType(SignUpForm), findsNothing);
      });
      testWidgets('back to previous page when arrow back is pressed',
          (tester) async {
        // whenListen(
        //   signUpCubit,
        //   Stream.fromIterable(const <SignUpState>[
        //     SignUpState(status: FormzStatus.submissionInProgress),
        //     SignUpState(status: FormzStatus.submissionSuccess),
        //   ]),
        // );
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        expect(find.byType(SignUpForm), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline));
        await tester.pumpAndSettle();
        expect(find.byType(SignUpForm), findsNothing);
      });
      testWidgets('unfocus', (tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            builder: (context, child) {
              return MaterialApp(
                home: Scaffold(
                  body: BlocProvider.value(
                    value: signUpCubit,
                    child: const SignUpForm(),
                  ),
                ),
              );
            },
          ),
        );
        expect(find.byType(SignUpForm), findsOneWidget);
        await tester.tap(find.byType(SingleChildScrollView));
        await tester.pumpAndSettle();
        expect(find.byType(SignUpForm), findsOneWidget);
      });
    });
  });
}
