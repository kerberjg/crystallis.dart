/// Crystallis API for custom serializers.
///
/// Extend [Serializer] to create custom serialization logic.
///
/// Example:
/// ```dart
/// import 'package:crystallis/api/serializer.dart';
///
/// class DateTimeSerializer extends Serializer<DateTime, String> {
///   @override
///   String serialize(DateTime value) => value.toIso8601String();
///
///   @override
///   DateTime deserialize(String value) => DateTime.parse(value);
/// }
/// ```
///
/// You can then...
///
/// - Register globally: all fields of type `DateTime` will use this serializer.
/// ```dart
/// Crystallis.i.registerSerializer<DateTime>(DateTimeSerializer());
/// ```
///
/// - Use as annotation on a specific field:
/// ```dart
/// @Crystallise()
/// class Event {
///   @DateTimeSerializer()
///   DateTime timestamp = DateTime.now();
/// }
///
/// @docImport 'package:crystallis/generated.dart';

library;

/// Abstract base class for custom serializers.
///
/// Implement this interface to create custom serializers.
///
/// See also:
/// - [Serializable], for inline serializer definitions
/// - [FieldMetadata.serializer], for field-level serializer configuration
///
abstract class Serializer<I, O> {
  /// Creates a [Serializer].
  const Serializer();

  /// Function that converts from type [I] to type [O]
  O serialize(I value);

  /// Function that converts from type [O] to type [I]
  I deserialize(O value);

  // HACK: This avoids runtime type errors when a typed `Serializer<T, O>` is stored
  // in an untyped location (for example, `FieldMetadata.serializer`).

  /// Serialize a value without requiring the caller to know [I].
  Object? serializeUntyped(Object? value) => serialize(value as I);

  /// Deserialize a value without requiring the caller to know [O].
  Object? deserializeUntyped(Object? value) => deserialize(value as O);
}

/// Specifies a custom serializer/deserializer annotation for a field.
///
/// Converts between type [I] (the field type) and type [O] (the serialized type).
///
/// Example:
/// ```dart
/// @Crystallise()
/// class Event {
///   @Serializable(
///     serialize: (value) => value.toIso8601String(),
///     deserialize: (value) => DateTime.parse(value),
///   )
///   DateTime timestamp = DateTime.now();
/// }
/// ```
///
/// See also:
/// - [Serializer], for class-based serializers
class Serializable<I, O> extends Serializer<I, O> {
  /// Function that converts from type [I] to type [O]
  final O Function(I value) _serialize;

  /// Function that converts from type [O] to type [I]
  final I Function(O value) _deserialize;

  /// Creates a [Serializable] with the given [serialize] and [deserialize] functions.
  const Serializable({
    required O Function(I value) serialize,
    required I Function(O value) deserialize,
  }) : _serialize = serialize,
       _deserialize = deserialize;

  @override
  O serialize(I value) => _serialize(value);
  @override
  I deserialize(O value) => _deserialize(value);
}
