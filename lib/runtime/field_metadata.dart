import 'package:meta/meta.dart';

import 'validator.dart';

@immutable
class FieldMetadata {
  final String name;
  final Type type;
  final List<Validator> validators;

  const FieldMetadata({
    required this.name,
    required this.type,
    required this.validators,
  });
}
