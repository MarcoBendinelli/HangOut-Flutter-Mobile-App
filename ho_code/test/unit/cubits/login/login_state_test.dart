// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:hang_out_app/business_logic/cubits/login/login_cubit.dart';
import 'package:hang_out_app/business_logic/form_inputs/email.dart';
import 'package:hang_out_app/business_logic/form_inputs/password.dart';

void main() {
  const email = Email.dirty('email');
  const password = Password.dirty('password');

  group('LoginState', () {
    test('supports value comparisons', () {
      expect(LoginState(), LoginState());
    });

    test('returns same object when no properties are passed', () {
      expect(LoginState().copyWith(), LoginState());
    });

    test('returns object with updated status when status is passed', () {
      expect(
        LoginState().copyWith(status: FormzStatus.pure),
        LoginState(),
      );
    });

    test('returns object with updated email when email is passed', () {
      expect(
        LoginState().copyWith(email: email),
        LoginState(email: email),
      );
    });

    test('returns object with updated password when password is passed', () {
      expect(
        LoginState().copyWith(password: password),
        LoginState(password: password),
      );
    });
  });
}
