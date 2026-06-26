import 'package:meta/meta_meta.dart';

import 'crystallis_singleton.dart';

/// Annotation for marking your data classes.
///
/// Apply [Crystallise] to a your class to generate a data class with
/// copy/get/set methods, validation, serialization, and other utilities.
///
/// Example (mutable):
/// ```dart
/// @Crystallise()
/// class User {
///   @NotEmpty()
///   String name = '';
///
///   @Range(0, 150)
///   int age = 0;
/// }
/// ```
///
/// For an immutable class, set `mutable: false` and make all fields `final` with a `const` constructor:
/// ```dart
/// @Crystallise(mutable: false)
/// class User {
///   @NotEmpty()
///   final String name = '';
/// }
/// ```
@Target({
  TargetKind.classType,
})
class Crystallise {
  /// Whether the generated data class is mutable (default: `true`)
  ///
  /// If `true`:
  ///  - Definition class fields must be non-final.
  ///  - Definition class must have a non-const default constructor.
  ///  - Generated data class fields will be non-final.
  ///  - Generated setter will modify fields in place
  ///
  /// If `false`:
  ///  - Definition class fields must be final.
  ///  - Definition class must have a const default constructor.
  ///  - Generated data class fields will be final.
  ///  - Generated setter will return a new instance with updated fields.
  final bool mutable;

  /// Whether a `toString` method should be generated (default: `true`).
  final bool enableToString;

  /// Whether an `equals` method should be generated (default: `true`).
  final bool enableEquals;

  /// Whether a `hashCode` method should be generated (default: `true`).
  final bool enableHashCode;

  /// Whether `hashCode` and `equals` should use deep collection equality
  /// for lists, sets, and maps (default: `false`).
  final bool useDeepEquality;

  /// Whether a `copyWith` method should be generated (default: `true`).
  final bool enableCopyWith;

  /// Whether `copyWith` should use deep collection copy for lists, sets, and maps (default: `false`).
  final bool useDeepCopy;

  /// Whether a `deserialize` constructor should be generated (default: `true`).
  final bool enableDeserialize;

  /// The [Crystallis] configuration for this data class (otherwise uses global config) See [Crystallis.i]. for global configuration.
  Crystallis get config => _config ?? Crystallis.i;
  final Crystallis? _config;

  /// Creates a [Crystallise] annotation.
  const Crystallise({
    this.mutable = true,
    // these are being redirected due to shorter naming
    bool toString = true,
    bool equals = true,
    bool hashCode = true,
    this.useDeepEquality = false,
    bool copyWith = true,
    this.useDeepCopy = false,
    bool deserialize = true,

    /// (see [config])
    Crystallis? config,
  }) : enableToString = toString,
       enableEquals = equals,
       enableHashCode = hashCode,
       enableCopyWith = copyWith,
       enableDeserialize = deserialize,
       _config = config;
}
