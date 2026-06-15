import 'package:crystallis/api/validator.dart';

/// [Validator] that checks if a value is not empty.
///
/// Works on [String], [Iterable], and [Map] fields.
///
/// Example:
/// ```dart
/// @Crystallise()
/// class User {
///   @NotEmpty()
///   String name = '';
///
///   @NotEmpty()
///   List<String> tags = [];
/// }
/// ```
///
/// See also:
/// - [Length], for specific length requirements
class NotEmpty extends Validator {
  /// Creates a [NotEmpty] validator.
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
