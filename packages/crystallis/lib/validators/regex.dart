import 'dart:core';

import '../runtime/validator.dart';

// ignore: public_member_api_docs
class RegEx extends Validator {
  /// The regex pattern to validate against.
  final String pattern;

  /// [Validator] that checks if a String value matches the given regex pattern.
  const RegEx(this.pattern);

  @override
  ValidationException? validate(Object? value) {
    final RegExp regex = RegExp(pattern);

    if (value is String) {
      if (!regex.hasMatch(value)) {
        return ValidationException(this, value);
      }

      return null;
    } else {
      return ValidationException(
        this,
        value,
        'Value must be a String type (is ${value.runtimeType})',
      );
    }
  }
}
