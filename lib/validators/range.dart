import '../runtime/validator.dart';

// ignore: public_member_api_docs
class Range extends Validator {
  /// (optional) The minimum value to check against.
  final num? min;

  /// (optional) The maximum value to check against.
  final num? max;

  /// Whether the range is inclusive (default: true).
  final bool inclusive;

  /// [Validator] that checks if a [num] value falls within a specified range.
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

// ignore: public_member_api_docs
class Min extends Range {
  /// [Validator] that checks if a [num] value is (equals or) above a minimum.
  /// (see [inclusive])
  const Min(num min, {super.inclusive}) : super(min: min);
}

// ignore: public_member_api_docs
class Max extends Range {
  /// [Validator] that checks if a [num] value is (equals or) below a maximum.
  /// (see [inclusive])
  const Max(num max, {super.inclusive}) : super(max: max);
}
