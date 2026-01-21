import 'package:crystallis/validators/regex.dart';

import '../runtime/validator.dart';

// ignore: public_member_api_docs
class AllowedChars extends Validator {
  /// The string containing all allowed characters.
  final String allowedChars;

  /// [Validator] that checks if a value contains only allowed characters.
  /// Works on [String] fields.
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

// ignore: public_member_api_docs
class Uppercase extends Validator {
  /// [Validator] that checks if a String value is all uppercase.
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

// ignore: public_member_api_docs
class Lowercase extends Validator {
  /// [Validator] that checks if a String value is all lowercase.
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

// ignore: public_member_api_docs
class OnlyNumbers extends RegEx {
  /// [Validator] that checks if a value contains only numeric characters.
  /// Works on [String] fields.
  const OnlyNumbers() : super(r'^[0-9]+$');
}

// ignore: public_member_api_docs
class OnlyLetters extends RegEx {
  /// [Validator] that checks if a value contains only letter characters.
  /// Works on [String] fields.
  const OnlyLetters() : super(r'^[a-zA-Z]+$');
}

// ignore: public_member_api_docs
class Alphanumeric extends RegEx {
  /// [Validator] that checks if a value contains only alphanumeric characters.
  /// Works on [String] fields.
  const Alphanumeric() : super(r'^[a-zA-Z0-9]+$');
}

// ignore: public_member_api_docs
class NoWhitespace extends Validator {
  /// [Validator] that checks if a value contains no whitespace.
  /// Works on [String] fields.
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
