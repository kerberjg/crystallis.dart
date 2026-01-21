import '../runtime/validator.dart';

// ignore: public_member_api_docs
class Length extends Validator {
  /// The exact length required.
  final int count;

  /// [Validator] that checks if a String value has the exact given length.
  const Length(this.count);

  @override
  ValidationException? validate(Object? value) {
    if (value is! String || value.length != count) {
      return ValidationException(this, value);
    }
    return null;
  }
}

// ignore: public_member_api_docs
class LengthRange extends Validator {
  /// (optional) The minimum length to check against.
  final int? min;

  /// (optional) The maximum length to check against.
  final int? max;

  /// Whether the range is inclusive (default: true).
  final bool inclusive;

  /// [Validator] that checks if the length falls within a specified range.
  /// Either [min], [max], or both must be provided.
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
