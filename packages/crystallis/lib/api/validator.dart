/// Crystallis API for custom validation annotations.
///
/// Extend [Validator] to create your own validators!
///
/// Example:
/// ```dart
/// import 'package:crystallis/api/validator.dart';
///
/// class Positive extends Validator {
///   const Positive();
///
///   @override
///   ValidationException? validate(Object? value) {
///     if (value is num && value > 0) return null;
///     return ValidationException(this, value, 'Must be positive');
///   }
/// }
/// ```
///
/// Then apply to a field like this:
/// ```dart
/// @Crystallise()
/// class Product {
///   @Positive()
///   num price = 0;
/// }
///
/// ...
///
/// final p = Product();
/// p.set('price', -5); // throws ValidationException
/// ```
///
/// See also:
/// - Built-in validators in [`package:crystallis/validators.dart`](../validators)
library;

/// An abstract class for validator annotations to be used with [CrystallisData].
///
/// Extend this class to create custom validators.
///
/// Example:
/// ```dart
/// class Positive extends Validator {
///   const Positive();
///
///   @override
///   ValidationException? validate(Object? value) {
///     if (value is num && value > 0) return null;
///     return ValidationException(this, value, 'Must be positive');
///   }
/// }
/// ```
///
/// See also:
/// - Built-in validators in `package:crystallis/validators.dart`
abstract class Validator {
  /// Creates a [Validator].
  const Validator();

  /// Validate the given [value].
  ///
  /// Return `null` if the value is valid, otherwise return a
  /// [ValidationException] with details about the failure.
  ValidationException? validate(Object? value);
}

/// Exception thrown when [Validator.validate] fails.
///
/// Contains the validator that failed, the invalid value,
/// and an optional reason string.
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
