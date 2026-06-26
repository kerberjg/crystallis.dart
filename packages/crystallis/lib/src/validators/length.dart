import 'package:crystallis/api/validator.dart';

/// [Validator] that checks if a String value has the exact given length.
///
/// Works on [String] fields.
///
/// Example:
/// ```dart
/// @Length(4)
/// String zipCode = '1234';
/// ```
///
/// See also:
/// - [LengthRange], for range-based length validation
class Length extends Validator {
  /// The exact length required.
  final int count;

  /// Creates a [Length] validator.
  const Length(this.count);

  @override
  ValidationException? validate(Object? value) {
    if (value is! String || value.length != count) {
      return ValidationException(this, value);
    }
    return null;
  }
}

/// [Validator] that checks if the length falls within a specified range.
///
/// Either [min], [max], or both must be provided.
///
/// Example:
/// ```dart
/// @LengthRange(min: 2, max: 50)
/// String name = 'John';
///
/// // Exclusive range
/// @LengthRange(min: 2, max: 10, inclusive: false)
/// String code = 'abc'; // Length must be > 2 and < 10
/// ```
///
/// See also:
/// - [Length], for exact length validation
class LengthRange extends Validator {
  /// (optional) The minimum length to check against.
  final int? min;

  /// (optional) The maximum length to check against.
  final int? max;

  /// Whether the range is inclusive (default: true).
  final bool inclusive;

  /// Creates a [LengthRange] validator.
  ///
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
