import 'package:analyzer/dart/constant/value.dart';

/// {@template crystallise}
/// A class representing the configuration options for the @Crystallise annotation. This class is used to parse the
/// annotation parameters and provide easy access to the configuration values for code generation.
/// {@endtemplate}
class Crystallise {
  /// {@macro crystallise}
  const Crystallise({
    required this.mutable,
    required this.enableToString,
    required this.enableEquals,
    required this.enableHashCode,
    required this.useDeepEquality,
    required this.enableCopyWith,
    required this.useDeepCopy,
    required this.enableDeserialize,
  });

  /// Parses a [DartObject] representing the @Crystallise annotation and returns a [Crystallise] instance with the
  /// corresponding configuration values. If a parameter is not specified in the annotation, it will default to the
  /// default value defined in the constructor.
  ///
  /// {@macro crystallise}
  factory Crystallise.parser(DartObject annotation) {
    var mutable = annotation.getField('mutable')?.toBoolValue() ?? false;
    var enableToString = annotation.getField('enableToString')?.toBoolValue() ?? true;
    var enableEquals = annotation.getField('enableEquals')?.toBoolValue() ?? true;
    var enableHashCode = annotation.getField('enableHashCode')?.toBoolValue() ?? true;
    var useDeepEquality = annotation.getField('useDeepEquality')?.toBoolValue() ?? false;
    var enableCopyWith = annotation.getField('enableCopyWith')?.toBoolValue() ?? true;
    var useDeepCopy = annotation.getField('useDeepCopy')?.toBoolValue() ?? false;
    var enableDeserialize = annotation.getField('enableDeserialize')?.toBoolValue() ?? true;
    return Crystallise(
      mutable: mutable,
      enableToString: enableToString,
      enableEquals: enableEquals,
      enableHashCode: enableHashCode,
      useDeepEquality: useDeepEquality,
      enableCopyWith: enableCopyWith,
      useDeepCopy: useDeepCopy,
      enableDeserialize: enableDeserialize,
    );
  }

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

  /// Whether a `copyWith` method should be generated.
  /// (default: true)
  final bool enableCopyWith;

  /// Whether `copyWith` should use deep collection copy for lists, sets, and maps.
  /// (default: false)
  final bool useDeepCopy;

  /// Whether a `deserialize` constructor should be generated.
  /// (default: true)
  final bool enableDeserialize;

  // TODO(FMorschel): Parse config.
}
