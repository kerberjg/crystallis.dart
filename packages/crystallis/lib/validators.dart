/// Crystallis built-in validation annotations.
///
/// Import this to use field-level validators like [Min], [Max],
/// [Email], [NotEmpty], etc.
///
/// Example:
/// ```dart
/// import 'package:crystallis/validators.dart';
///
/// @Crystallise()
/// class User {
///   @Email()
///   String email = '';
/// }
/// ```
///
/// See also:
/// - [ValidationException], thrown when validation fails
/// - `package:crystallis/api/validator.dart`, for writing your own validator annotations
library;

export 'api/validator.dart' show ValidationException;

export 'src/validators/range.dart';
export 'src/validators/not_empty.dart';
export 'src/validators/email.dart';
export 'src/validators/chars.dart';
export 'src/validators/length.dart';
export 'src/validators/values.dart';
export 'src/validators/regex.dart';
