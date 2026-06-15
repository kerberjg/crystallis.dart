import 'package:crystallis/api/validator.dart';

/// [Validator] that checks if a [num] value falls within a specified range.
///
/// Either [min], [max], or both must be provided.
///
/// Example:
/// ```dart
/// @Range(min: 0, max: 100)
/// int age = 25;
///
/// // Exclusive range
/// @Range(min: 0, max: 100, inclusive: false)
/// int age = 25; // Must be > 0 and < 100
/// ```
///
/// See also:
/// - [Min], for minimum-only validation
/// - [Max], for maximum-only validation
class Range extends Validator {
  /// (optional) The minimum value to check against.
  final num? min;

  /// (optional) The maximum value to check against.
  final num? max;

  /// Whether the range is inclusive (default: true).
  final bool inclusive;

  /// Creates a [Range] validator.
  ///
  /// Either [min], [max], or both must be provided.
  const Range({this.min, this.max, this.inclusive = true})
    : assert(
        min != null || max != null,
        'At least one of min or max must be provided.',
      );

  @override
  ValidationException? validate(Object? value) {
    if (value is! num) {
      return ValidationException(this, value);
    }

    if (min != null) {
      if (inclusive ? value < min! : value <= min!) {
        return ValidationException(this, value);
      }
    }

    if (max != null) {
      if (inclusive ? value > max! : value >= max!) {
        return ValidationException(this, value);
      }
    }

    return null;
  }
}

/// [Validator] that checks if a [num] value is (equals or) above a minimum.
///
/// Example:
/// ```dart
/// @Min(0)
/// int age = 0;
///
/// @Min(18, inclusive: false)
/// int age = 19; // Must be > 18
/// ```
///
/// See also:
/// - [Max], for maximum validation
/// - [Range], for both minimum and maximum
class Min extends Range {
  /// Creates a [Min] validator.
  ///
  /// [min] is the minimum allowed value (inclusive by default).
  /// Use [inclusive] to make it exclusive.
  const Min(num min, {super.inclusive}) : super(min: min);
}

/// [Validator] that checks if a [num] value is (equals or) below a maximum.
///
/// Example:
/// ```dart
/// @Max(150)
/// int age = 100;
///
/// @Max(100, inclusive: false)
/// int age = 99; // Must be < 100
/// ```
///
/// See also:
/// - [Min], for minimum validation
/// - [Range], for both minimum and maximum
class Max extends Range {
  /// Creates a [Max] validator.
  ///
  /// [max] is the maximum allowed value (inclusive by default).
  /// Use [inclusive] to make it exclusive.
  const Max(num max, {super.inclusive}) : super(max: max);
}
