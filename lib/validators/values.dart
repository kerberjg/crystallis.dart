import '../runtime/validator.dart';

// ignore: public_member_api_docs
class AllowedValues extends Validator {
  /// The given set of allowed values.
  final Set<dynamic> values;

  /// [Validator] that checks if a value is within a set of allowed values.
  const AllowedValues(this.values);

  @override
  ValidationException? validate(Object? value) {
    if (!values.contains(value)) {
      return ValidationException(this, value);
    }
    return null;
  }
}
