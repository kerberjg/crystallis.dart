import 'package:crystallis/runtime/serializer.dart';

import 'validator.dart';

/// Metadata of a field in a [CrystallisData] class.
class FieldMetadata {
  /// Name of the field.
  final String name;

  /// Type of the field.
  final Type type;

  /// Whether the field is nullable (i.e. can be `null`).
  final bool nullable;

  /// Whether the field is mutable (non-final).
  final bool mutable;

  /// List of applied validators.
  final List<Validator> validators;

  /// Custom serializer for the field.
  final Serializer serializer;

  /// Creates a [FieldMetadata].
  const FieldMetadata({
    required this.name,
    required this.type,
    this.nullable = false,
    this.mutable = false,
    required this.validators,
    this.serializer = fallbackSerializer,
  });

  @override
  String toString() {
    return 'FieldMetadata(name: $name, type: $type, nullable: $nullable, mutable: $mutable, validators: $validators, serializer: $serializer)';
  }
}
