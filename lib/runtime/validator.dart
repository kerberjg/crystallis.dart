/// An abstract class for validator annotations to be used with [CrystallisData].
abstract class Validator {
  /// Creates a [Validator].
  const Validator();

  /// Return null if valid, otherwise a ValidationException.
  ValidationException? validate(Object? value);
}

/// Exception thrown when [Validator.validate] fails.
class ValidationException implements Exception {
  /// The validator that failed.
  final Validator validator;

  /// The invalid value.
  final Object? value;

  /// (optional) The reason for the validation failure.
  final String? reason;

  /// Creates a [ValidationException].
  const ValidationException(
    this.validator,
    this.value, [
    this.reason,
  ]);

  @override
  String toString() => '$runtimeType(validator: ${validator.runtimeType}, value: $value)';
}
