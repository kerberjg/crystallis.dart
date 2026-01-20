import '../runtime/validator.dart';

class Range extends Validator {
  final num? min;
  final num? max;
  final bool inclusive;

  const Range({this.min, this.max, this.inclusive = true});

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
