abstract class Validator {
  const Validator();

  /// Return null if valid, otherwise a ValidationException.
  ValidationException? validate(Object? value);
}

class ValidationException implements Exception {
  final Validator validator;
  final Object? value;

  const ValidationException(
    this.validator,
    this.value,
  );

  @override
  String toString() =>
      '$runtimeType(validator: ${validator.runtimeType}, value: $value)';
}
