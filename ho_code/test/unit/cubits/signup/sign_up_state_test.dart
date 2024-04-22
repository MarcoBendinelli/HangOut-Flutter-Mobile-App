// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:hang_out_app/business_logic/cubits/sign_up/sign_up_cubit.dart';
import 'package:hang_out_app/business_logic/form_inputs/confirmed_password.dart';
import 'package:hang_out_app/business_logic/form_inputs/email.dart';
import 'package:hang_out_app/business_logic/form_inputs/name.dart';
import 'package:hang_out_app/business_logic/form_inputs/password.dart';

void main() {
  const email = Email.dirty('email');
  const passwordString = 'password';
  const password = Password.dirty(passwordString);
  const name = Name.dirty('name');
  const confirmedPassword = ConfirmedPassword.dirty(
    password: passwordString,
    value: passwordString,
  );

  group('SignUpState', () {
    test('supports value comparisons', () {
      expect(SignUpState(), SignUpState());
    });

    test('returns same object when no properties are passed', () {
      expect(SignUpState().copyWith(), SignUpState());
    });

    test('returns object with updated status when status is passed', () {
      expect(
        SignUpState().copyWith(status: FormzStatus.pure),
        SignUpState(),
      );
    });

    test('returns object with updated email when email is passed', () {
      expect(
        SignUpState().copyWith(email: email),
        SignUpState(email: email),
      );
    });

    test('returns object with updated password when password is passed', () {
      expect(
        SignUpState().copyWith(password: password),
        SignUpState(password: password),
      );
    });

    test('returns object with updated name when name is passed', () {
      expect(
        SignUpState().copyWith(name: name),
        SignUpState(name: name),
      );
    });

    test(
        'returns object with updated confirmedPassword'
        ' when confirmedPassword is passed', () {
      expect(
        SignUpState().copyWith(confirmedPassword: confirmedPassword),
        SignUpState(confirmedPassword: confirmedPassword),
      );
    });
  });
}
