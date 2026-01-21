import 'package:meta/meta.dart';

import 'validator.dart';

/// Metadata of a field in a [CrystallisData] class.
@immutable
class FieldMetadata {
  /// Name of the field.
  final String name;

  /// Type of the field.
  final Type type;

  /// List of applied validators.
  final List<Validator> validators;

  /// Creates a [FieldMetadata].
  const FieldMetadata({
    required this.name,
    required this.type,
    required this.validators,
  });
}
