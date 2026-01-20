import '../runtime/validator.dart';

class NotEmpty extends Validator {
  const NotEmpty();

  @override
  ValidationException? validate(Object? value) {
    if (value == null) {
      return ValidationException(this, value);
    }

    if (value is String && value.isNotEmpty) return null;
    if (value is Iterable && value.isNotEmpty) return null;
    if (value is Map && value.isNotEmpty) return null;

    return ValidationException(this, value);
  }
}
