import 'field_metadata.dart';
import 'validator.dart';

/// Mixin class that provides validation functionality for data classes.
/// Applied to classes generated with [CrystallisData].
abstract mixin class CrystallisMixin {
  /// Per-field metadata of this data class.
  Map<String, FieldMetadata> get metadata;

  /// Get the value of a field by name.
  /// To see what type it might be, check [metadata].
  /// (see [FieldMetadata.type])
  Object? get(String field);

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

  /// Copies compatible fields from any [other] instance of [CrystallisMixin].
  /// Incompatible fields (missing or type-mismatched) are skipped.
  /// Null values are skipped.
  void copyFrom(CrystallisMixin other) {
    // skip this both this and other are of the same type
    final bool isSameType = this.runtimeType != other.runtimeType;

    for (final name in metadata.keys) {
      if (!isSameType) {
        final field = metadata[name]!;
        final otherMeta = other.metadata[name];

        /// TODO(kerberjg): dart-format-off is not working here...
        // skip when...
        if ( //
            otherMeta == null // missing
                ||
                otherMeta.type != field.type // type-mismatched fields
                ||
                !field.mutable // this field is immutable
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

  // TODO(kerberjg): deserialize factory method?
  // Should:
  // - be a callable from a factory constructor in the generated class
  // - take a Map<String, dynamic>
  // - return an instance of the generated class
  // - use the per-field serializers to deserialize each field
  // - validate each field after deserialization
}
