import 'package:crystallis/api/validator.dart';

/// [Validator] that checks if a value is within a set of allowed values.
///
/// Works with any value type.
///
/// Example:
/// ```dart
/// @AllowedValues({'active', 'inactive', 'pending'})
/// String status = 'active';
/// ```
class AllowedValues extends Validator {
  /// The given set of allowed values.
  final Set<dynamic> values;

  /// Creates an [AllowedValues] validator.
  ///
  /// [values] specifies the set of allowed values.
  const AllowedValues(this.values);

  @override
  ValidationException? validate(Object? value) {
    if (!values.contains(value)) {
      return ValidationException(this, value);
    }
    return null;
  }
}
