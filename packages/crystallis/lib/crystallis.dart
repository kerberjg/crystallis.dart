/// Crystallis - Data class codegen with validation, serialization and reflection.
///
/// Import this to use the [Crystallise] annotation and write data classes.
///
/// Example:
/// ```dart
/// import 'package:crystallis/crystallis.dart';
///
/// @Crystallise()
/// class User {
///   @NotEmpty()
///   String name = '';
///
///   @Range(0, 150)
///   int age = 0;
/// }
/// ```
library;

export 'src/crystallise_annotation.dart';
export 'src/crystallis_singleton.dart';
