import 'package:meta/meta.dart';

export 'validators/range.dart';
export 'validators/not_empty.dart';
export 'validators/email.dart';
export 'validators/chars.dart';
export 'validators/length.dart';
export 'validators/values.dart';
export 'validators/regex.dart';

/// Creates a [CrystallisData] annotation.
@immutable
class CrystallisData {
  /// Whether the generated data class is mutable.
  /// (default: true)
  ///
  /// If true:
  ///  - Definition class fields must be non-final.
  ///  - Definition class must have a non-const default constructor.
  ///  - Generated data class fields will be non-final.
  ///  - Generated setter will modify fields in place.
  ///
  /// If false:
  ///  - Definition class fields must be final.
  ///  - Definition class must have a const default constructor.
  ///  - Generated data class fields will be final.
  ///  - Generated setter will return a new instance with updated fields.
  final bool mutable;

  /// Annotation to configure data class behavior.
  /// Allows specifying whether the generated data class is [mutable].
  const CrystallisData({this.mutable = true});
}
