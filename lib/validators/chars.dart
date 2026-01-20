import 'package:crystallis/validators/regex.dart';

import '../runtime/validator.dart';

class AllowedChars extends Validator {
  final String allowedChars;

  const AllowedChars(this.allowedChars);

  @override
  ValidationException? validate(Object? value) {
    if (value is String) {
      for (var char in value.split('')) {
        if (!allowedChars.contains(char)) {
          return ValidationException(this, value);
        }
      }
    }
    return null;
  }
}

class Uppercase extends Validator {
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

class Lowercase extends Validator {
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

class OnlyNumbers extends RegEx {
  const OnlyNumbers() : super(r'^[0-9]+$');
}

class OnlyLetters extends RegEx {
  const OnlyLetters() : super(r'^[a-zA-Z]+$');
}

class Alphanumeric extends RegEx {
  const Alphanumeric() : super(r'^[a-zA-Z0-9]+$');
}

class NoWhitespace extends Validator {
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
