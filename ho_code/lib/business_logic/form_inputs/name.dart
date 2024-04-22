import 'package:formz/formz.dart';

/// Validation errors for the [Name] [FormzInput].
enum NameValidationError {
  /// Generic invalid error.
  invalid
}

/// {@template name}
/// Form input for a name input.
/// {@endtemplate}
class Name extends FormzInput<String, NameValidationError> {
  /// {@macro name}
  const Name.pure() : super.pure('');

  /// {@macro nametest}
  const Name.dirty([super.value = '']) : super.dirty();

  static final RegExp _emailRegExp = RegExp(
    r'^[A-Z][-a-zA-Z]+$',
  );

  @override
  NameValidationError? validator(String? value) {
    return _emailRegExp.hasMatch(value ?? '')
        ? null
        : NameValidationError.invalid;
  }
}
