import '../runtime/validator.dart';

class AllowedValues extends Validator {
  final List<dynamic> values;

  const AllowedValues(this.values);

  @override
  ValidationException? validate(Object? value) {
    if (!values.contains(value)) {
      return ValidationException(this, value);
    }
    return null;
  }
}
