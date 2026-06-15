import 'dart:core';

import 'package:crystallis/api/validator.dart';

/// [Validator] that checks if a String value matches the given regex pattern.
///
/// Works on [String] fields.
///
/// Example:
/// ```dart
/// @RegEx(r'^[A-Z]{2}\d{4}$')
/// String code = 'US1234';
/// ```
///
/// See also:
/// - [Email], which uses [RegEx] internally
class RegEx extends Validator {
  /// The regex pattern to validate against.
  final String pattern;

  /// Creates a [RegEx] validator.
  ///
  /// [pattern] is the regex pattern to match against.
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
