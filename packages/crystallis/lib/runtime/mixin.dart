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
}
