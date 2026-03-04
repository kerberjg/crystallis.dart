import 'package:crystallis/annotations.dart';
import 'package:meta/meta.dart';

import 'field_metadata.dart';
import 'validator.dart';

/// Sentinel value used to represent true nullability in [copyWith] parameters.
enum _NullableSentinel { i }

/// Mixin class that provides validation functionality for data classes.
/// Applied to classes generated with [Crystallise].
abstract mixin class CrystallisData {
  /// Per-field metadata of this data class.
  Map<String, FieldMetadata> get metadata;

  /// [Crystallise] configuration
  @protected
  Crystallise get config;

  /// Nullable value sentinel used in generated [copyWith] methods.
  @protected
  // ignore: library_private_types_in_public_api
  static const _NullableSentinel nullValue = _NullableSentinel.i;

  /// Get the value of a field by name.
  /// To see what type it might be, check [metadata].
  ///
  /// Throws an [ArgumentError] if the field does not exist.
  ///
  /// (see [FieldMetadata.type])
  Object? get(String field);

  /// Try to get the value of a field by name,
  /// returning `null` if:
  /// - the field does not exist
  /// - the field value is not of type [T]
  /// - any [ArgumentError] is thrown during retrieval
  ///
  /// (see [get])
  T? tryGet<T>(String field) {
    try {
      final value = get(field);
      return value is T ? value : null;
    } on ArgumentError {
      return null;
    }
  }

  /// Set the value of a field by name.
  void set<T>(String field, T value);

  /// Validate a single field
  List<ValidationException> validateField(String field) {
    final meta = metadata[field];
    if (meta == null) {
      throw ArgumentError.value(field, 'field');
    }

    final value = get(field);
    final errors = <ValidationException>[];

    for (final v in meta.validators) {
      final err = v.validate(value);
      if (err != null) {
        errors.add(err);
      }
    }

    return errors;
  }

  /// Validate all fields (including those with zero validators)
  Map<String, List<ValidationException>> validate() {
    final result = <String, List<ValidationException>>{};

    for (final field in metadata.keys) {
      result[field] = validateField(field);
    }

    return result;
  }

  /// Asserts that the field can be set with the given value,
  /// and throws [List<ValidationException>] if any validators fail.
  /// Throws [ArgumentError] if the field does not exist or if the value is of the wrong type.
  void assertSet<T>(String field, T value) {
    final meta = metadata[field];
    if (meta == null) throw ArgumentError.value(field, 'field');
    if (value == null || value.runtimeType != meta.type) {
      throw TypeError();
    }

    final errors = <ValidationException>[];
    for (final v in meta.validators) {
      final err = v.validate(value);
      if (err != null) errors.add(err);
    }
    if (errors.isNotEmpty) throw errors;
  }

  /// Copies compatible fields from any [other] instance of [CrystallisData].
  /// Incompatible fields (missing or type-mismatched) are skipped.
  /// Null values are skipped.
  void setFrom(CrystallisData other);

  /// Serializes this object into a [Map<String, dynamic>]
  Map<String, dynamic> serialize() {
    final result = <String, dynamic>{};

    for (final field in metadata.keys) {
      final value = get(field);
      final serializer = metadata[field]!.serializer;
      result[field] = serializer.serializeUntyped(value);
    }

    return result;
  }
}

/// Mutable variant of [CrystallisData].
/// Used on generated data classes when [Crystallise.mutable] is true.
abstract mixin class MutableCrystallisData implements CrystallisData {
  @override
  void setFrom(CrystallisData other) {
    // skip this both this and other are of the same type
    final bool isSameType = this.runtimeType == other.runtimeType;

    for (final name in metadata.keys) {
      if (!isSameType) {
        final thisMeta = metadata[name]!;
        final otherMeta = other.metadata[name];

        /// TODO(kerberjg): dart-format-off is not working here...
        // skip when...
        if ( //
        otherMeta ==
                null // missing
                ||
            otherMeta.type !=
                thisMeta
                    .type // type-mismatched fields
                    ||
            !thisMeta
                .mutable // this field is immutable
                ) {
          continue;
        }
      }

      final value = other.get(name);

      // skip null values
      if (value != null) {
        set(name, value);
      }
    }
  }
}

/// Immutable variant of [CrystallisData].
/// Used on generated data classes when [Crystallise.mutable] is false.
abstract mixin class ImmutableCrystallisData implements CrystallisData {
  /// Always throws an [StateError] since immutable data classes
  /// cannot be modified.
  @override
  void set<T>(String field, T value) {
    throw StateError(
      'Cannot set field "$field" on immutable data class',
    );
  }

  /// Always throws an [StateError] since immutable data classes
  /// cannot be modified.
  @override
  void setFrom(CrystallisData other) {
    throw StateError(
      'Cannot set fields from another instance on immutable data class',
    );
  }
}
