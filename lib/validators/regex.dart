import 'dart:core';

import '../runtime/validator.dart';

class RegEx extends Validator {
  final String pattern;

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
