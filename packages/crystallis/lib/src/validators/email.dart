import 'regex.dart';

/// [Validator] that checks if a String value is a valid email address.
///
/// Uses a basic regex pattern: `^[^@\s]+@[^@\s]+\.[^@\s]+$`
///
/// Example:
/// ```dart
/// @Crystallise()
/// class User {
///   @Email()
///   String email = 'user@example.com';
/// }
/// ```
///
/// See also:
/// - [RegEx], for custom pattern validation
class Email extends RegEx {
  /// Creates an [Email] validator.
  const Email() : super(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
}
