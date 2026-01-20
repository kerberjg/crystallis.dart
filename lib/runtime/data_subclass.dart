import 'field_metadata.dart';
import 'validator.dart';

abstract mixin class DataSubclass {
  Map<String, FieldMetadata> get metadata;
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
