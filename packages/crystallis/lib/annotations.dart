export 'validators/range.dart';
export 'validators/not_empty.dart';
export 'validators/email.dart';
export 'validators/chars.dart';
export 'validators/length.dart';
export 'validators/values.dart';
export 'validators/regex.dart';

// External exports
export 'package:meta/meta.dart' show immutable;
export 'package:collection/collection.dart' show DeepCollectionEquality;

/// Creates a [CrystallisData] annotation.
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

  /// Whether a `toString` method should be generated.
  /// (default: true)
  final bool enableToString;

  /// Whether an `equals` method should be generated.
  /// (default: true)
  final bool enableEquals;

  /// Whether a `hashCode` method should be generated.
  /// (default: true)
  final bool enableHashCode;

  /// Whether `hashCode` and `equals` should use deep collection equality
  /// for lists, sets, and maps.
  /// (default: false)
  final bool useDeepEquality;

  /// Annotation to configure data class behavior.
  /// Allows specifying whether the generated data class is [mutable].
  const CrystallisData({
    this.mutable = true,
    // these are being redirected due to shorter naming
    bool toString = true,
    bool equals = true,
    bool hashCode = true,
    this.useDeepEquality = false,
  })  : enableToString = toString,
        enableEquals = equals,
        enableHashCode = hashCode;
}
