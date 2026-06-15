import 'package:crystallis/api/validator.dart';
import 'regex.dart';

/// [Validator] that checks if a value contains only allowed characters.
///
/// Works on [String] fields.
///
/// Example:
/// ```dart
/// @AllowedChars('abcdefghijklmnopqrstuvwxyz')
/// String username = 'john';
/// ```
class AllowedChars extends Validator {
  /// The string containing all allowed characters.
  final String allowedChars;

  /// Creates an [AllowedChars] validator.
  ///
  /// [allowedChars] specifies the characters that are allowed.
  const AllowedChars(this.allowedChars);

  @override
  ValidationException? validate(Object? value) {
    if (value is String) {
      for (var char in value.split('')) {
        if (!allowedChars.contains(char)) {
          return ValidationException(this, value);
        }
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

/// [Validator] that checks if a String value is all uppercase.
///
/// Works on [String] fields.
///
/// Example:
/// ```dart
/// @Uppercase()
/// String code = 'ABC';
/// ```
class Uppercase extends Validator {
  /// Creates an [Uppercase] validator.
  const Uppercase();

  @override
  ValidationException? validate(Object? value) {
    if (value is String) {
      if (value != value.toUpperCase()) {
        return ValidationException(this, value);
      }
    }
    return null;
  }
}

/// [Validator] that checks if a String value is all lowercase.
///
/// Works on [String] fields.
///
/// Example:
/// ```dart
/// @Lowercase()
/// String code = 'abc';
/// ```
class Lowercase extends Validator {
  /// Creates a [Lowercase] validator.
  const Lowercase();

  @override
  ValidationException? validate(Object? value) {
    if (value is String) {
      if (value != value.toLowerCase()) {
        return ValidationException(this, value);
      }
    }
    return null;
  }
}

/// [Validator] that checks if a value contains only numeric characters.
///
/// Works on [String] fields.
///
/// Example:
/// ```dart
/// @OnlyNumbers()
/// String zipCode = '12345';
/// ```
///
/// See also:
/// - [Alphanumeric], for letters and numbers
/// - [OnlyLetters], for letters only
class OnlyNumbers extends RegEx {
  /// Creates an [OnlyNumbers] validator.
  const OnlyNumbers() : super(r'^[0-9]+$');
}

/// [Validator] that checks if a value contains only letter characters.
///
/// Works on [String] fields.
///
/// Example:
/// ```dart
/// @OnlyLetters()
/// String name = 'John';
/// ```
///
/// See also:
/// - [Alphanumeric], for letters and numbers
/// - [OnlyNumbers], for numbers only
class OnlyLetters extends RegEx {
  /// Creates an [OnlyLetters] validator.
  const OnlyLetters() : super(r'^[a-zA-Z]+$');
}

/// [Validator] that checks if a value contains only alphanumeric characters.
///
/// Works on [String] fields.
///
/// Example:
/// ```dart
/// @Alphanumeric()
/// String username = 'user123';
/// ```
///
/// See also:
/// - [OnlyLetters], for letters only
/// - [OnlyNumbers], for numbers only
class Alphanumeric extends RegEx {
  /// Creates an [Alphanumeric] validator.
  const Alphanumeric() : super(r'^[a-zA-Z0-9]+$');
}

/// [Validator] that checks if a value contains no whitespace.
///
/// Works on [String] fields.
///
/// Example:
/// ```dart
/// @NoWhitespace()
/// String username = 'john_doe';
/// ```
class NoWhitespace extends Validator {
  /// Creates a [NoWhitespace] validator.
  const NoWhitespace();

  @override
  ValidationException? validate(Object? value) {
    if (value is String) {
      if (value.contains(RegExp(r'\s'))) {
        return ValidationException(this, value);
      }
    }
    return null;
  }
}
