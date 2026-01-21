import '../runtime/validator.dart';

// ignore: public_member_api_docs
class NotEmpty extends Validator {
  /// [Validator] that checks if a value is not empty.
  /// Works on [String], [Iterable], [Map] fields.
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
