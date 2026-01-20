import '../runtime/validator.dart';

class Length extends Validator {
  final int count;

  const Length(this.count);

  @override
  ValidationException? validate(Object? value) {
    if (value is! String || value.length != count) {
      return ValidationException(this, value);
    }
    return null;
  }
}

class LengthRange extends Validator {
  final int? min;
  final int? max;
  final bool inclusive;

  const LengthRange({this.min, this.max, this.inclusive = true});

  @override
  ValidationException? validate(Object? value) {
    if (value is! String) {
      return ValidationException(this, value);
    }

    final len = value.length;

    if (min != null) {
      if (inclusive ? len < min! : len <= min!) {
        return ValidationException(this, value);
      }
    }

    if (max != null) {
      if (inclusive ? len > max! : len >= max!) {
        return ValidationException(this, value);
      }
    }

    return null;
  }
}
