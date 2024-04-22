// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:formz/formz.dart';
import 'package:hang_out_app/business_logic/cubits/sign_up/sign_up_cubit.dart';
import 'package:hang_out_app/business_logic/form_inputs/confirmed_password.dart';
import 'package:hang_out_app/business_logic/form_inputs/email.dart';
import 'package:hang_out_app/business_logic/form_inputs/name.dart';
import 'package:hang_out_app/business_logic/form_inputs/password.dart';
import 'package:hang_out_app/data/repositories/authentication_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockXfile extends Mock implements XFile {}

void main() {
  const invalidEmailString = 'invalid';
  const invalidEmail = Email.dirty(invalidEmailString);

  const validEmailString = 'test@gmail.com';
  const validEmail = Email.dirty(validEmailString);

  const invalidPasswordString = 'invalid';
  const invalidPassword = Password.dirty(invalidPasswordString);

  const validPasswordString = 't0pS3cret1234';
  const validPassword = Password.dirty(validPasswordString);

  const invalidConfirmedPasswordString = 'invalid';
  const invalidConfirmedPassword = ConfirmedPassword.dirty(
    password: validPasswordString,
    value: invalidConfirmedPasswordString,
  );

  const validConfirmedPasswordString = 't0pS3cret1234';
  const validConfirmedPassword = ConfirmedPassword.dirty(
    password: validPasswordString,
    value: validConfirmedPasswordString,
  );

  const validNameString = 'Pippo';
  const validName = Name.dirty(validNameString);
  const invalidNameString = 'Pippo';
  const invalidName = Name.dirty(invalidNameString);
  final MockXfile validPhoto = MockXfile();

  group('SignUpCubit', () {
    late AuthenticationRepository authenticationRepository;

    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
      when(
        () => authenticationRepository.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name')),
      ).thenAnswer((_) async {});
    });

    test('initial state is SignUpState', () {
      expect(SignUpCubit(authenticationRepository).state, SignUpState());
    });

    group('emailChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.emailChanged(invalidEmailString),
        expect: () => const <SignUpState>[
          SignUpState(email: invalidEmail, status: FormzStatus.invalid),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          name: validName,
          password: validPassword,
          confirmedPassword: validConfirmedPassword,
        ),
        act: (cubit) => cubit.emailChanged(validEmailString),
        expect: () => const <SignUpState>[
          SignUpState(
            name: validName,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );
    });

    group('passwordChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.passwordChanged(invalidPasswordString),
        expect: () => const <SignUpState>[
          SignUpState(
            confirmedPassword: ConfirmedPassword.dirty(
              password: invalidPasswordString,
            ),
            password: invalidPassword,
            status: FormzStatus.invalid,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          email: validEmail,
          confirmedPassword: validConfirmedPassword,
          name: validName,
        ),
        act: (cubit) => cubit.passwordChanged(validPasswordString),
        expect: () => const <SignUpState>[
          SignUpState(
            name: validName,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when confirmedPasswordChanged is called first and then '
        'passwordChanged is called',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          email: validEmail,
          name: validName,
        ),
        act: (cubit) => cubit
          ..confirmedPasswordChanged(validConfirmedPasswordString)
          ..passwordChanged(validPasswordString),
        expect: () => const <SignUpState>[
          SignUpState(
            name: validName,
            email: validEmail,
            confirmedPassword: validConfirmedPassword,
            status: FormzStatus.invalid,
          ),
          SignUpState(
            name: validName,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );
    });

    group('confirmedPasswordChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) {
          cubit.confirmedPasswordChanged(invalidConfirmedPasswordString);
        },
        expect: () => const <SignUpState>[
          SignUpState(
            confirmedPassword: invalidConfirmedPassword,
            status: FormzStatus.invalid,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
            email: validEmail, password: validPassword, name: validName),
        act: (cubit) => cubit.confirmedPasswordChanged(
          validConfirmedPasswordString,
        ),
        expect: () => const <SignUpState>[
          SignUpState(
            name: validName,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when passwordChanged is called first and then '
        'confirmedPasswordChanged is called',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          email: validEmail,
          name: validName,
        ),
        act: (cubit) => cubit
          ..passwordChanged(validPasswordString)
          ..confirmedPasswordChanged(validConfirmedPasswordString),
        expect: () => const <SignUpState>[
          SignUpState(
            name: validName,
            email: validEmail,
            password: validPassword,
            confirmedPassword: ConfirmedPassword.dirty(
              password: validPasswordString,
            ),
            status: FormzStatus.invalid,
          ),
          SignUpState(
            name: validName,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );
    });

    group('signUpFormSubmitted', () {
      blocTest<SignUpCubit, SignUpState>(
        'does nothing when status is not validated',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => const <SignUpState>[],
      );

      blocTest<SignUpCubit, SignUpState>(
        'calls signUp with correct email/password/confirmedPassword',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          status: FormzStatus.valid,
          email: validEmail,
          password: validPassword,
          name: validName,
          confirmedPassword: validConfirmedPassword,
        ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        verify: (_) {
          verify(
            () => authenticationRepository.signUp(
                email: validEmailString,
                password: validPasswordString,
                name: validNameString),
          ).called(1);
        },
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [submissionInProgress, submissionSuccess] '
        'when signUp succeeds',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          status: FormzStatus.valid,
          email: validEmail,
          password: validPassword,
          confirmedPassword: validConfirmedPassword,
        ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => const <SignUpState>[
          SignUpState(
            status: FormzStatus.submissionInProgress,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          ),
          SignUpState(
            status: FormzStatus.submissionSuccess,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          )
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [submissionInProgress, submissionFailure] '
        'when signUp fails due to SignUpWithEmailAndPasswordFailure',
        setUp: () {
          when(
            () => authenticationRepository.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
            ),
          ).thenThrow(SignUpWithEmailAndPasswordFailure('oops'));
        },
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          status: FormzStatus.valid,
          email: validEmail,
          password: validPassword,
          confirmedPassword: validConfirmedPassword,
        ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => const <SignUpState>[
          SignUpState(
            status: FormzStatus.submissionInProgress,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          ),
          SignUpState(
            status: FormzStatus.submissionFailure,
            errorMessage: 'oops',
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          )
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [submissionInProgress, submissionFailure] '
        'when signUp fails due to generic exception',
        setUp: () {
          when(
            () => authenticationRepository.signUp(
                email: any(named: 'email'),
                password: any(named: 'password'),
                name: any(named: 'name')),
          ).thenThrow(Exception('oops'));
        },
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          status: FormzStatus.valid,
          email: validEmail,
          password: validPassword,
          confirmedPassword: validConfirmedPassword,
        ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => const <SignUpState>[
          SignUpState(
            status: FormzStatus.submissionInProgress,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          ),
          SignUpState(
            status: FormzStatus.submissionFailure,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          )
        ],
      );
    });

    group('nameChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.nameChanged(invalidNameString),
        expect: () => const <SignUpState>[
          SignUpState(name: invalidName, status: FormzStatus.invalid),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          email: validEmail,
          password: validPassword,
          confirmedPassword: validConfirmedPassword,
        ),
        act: (cubit) => cubit.nameChanged(validNameString),
        expect: () => const <SignUpState>[
          SignUpState(
            name: validName,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );
    });

    group('photoChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState(
          name: validName,
          email: validEmail,
          password: validPassword,
          confirmedPassword: validConfirmedPassword,
        ),
        act: (cubit) => cubit.photoChanged(validPhoto),
        expect: () => <SignUpState>[
          SignUpState(
            name: validName,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
            photo: validPhoto,
            status: FormzStatus.valid,
          ),
        ],
      );
    });
  });
}
