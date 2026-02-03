import 'package:crystallis/crystallis.dart';

/// Specifies a custom serializer/deserializer annotation for a field
/// Converts between type [T] (the field type) and type [U] (the serialized type)
class Serializer<T, U> {
  /// Function that converts from type [T] to type [U]
  final U Function(T value) serialize;

  /// Function that converts from type [U] to type [T]
  final T Function(U value) deserialize;

  /// Creates a [Serializer] with the given [serialize] and [deserialize] functions
  const Serializer({
    required this.serialize,
    required this.deserialize,
  });

  // HACK: This avoids runtime type errors when a typed `Serializer<T, U>` is stored
  // in an untyped location (for example, `FieldMetadata.serializer`).

  /// Serialize a value without requiring the caller to know [T].
  Object? serializeUntyped(Object? value) => serialize(value as T);

  /// Deserialize a value without requiring the caller to know [U].
  Object? deserializeUntyped(Object? value) => deserialize(value as U);
}

/// Default [Serializer] that handles basic types and nested [CrystallisMixin]..
/// See [serialize] and [deserialize] functions for details.
const defaultSerializer = Serializer<Object?, Object?>(
  serialize: serialize,
  deserialize: deserialize,
);

/// Basic serialization function. Handles:
/// - Primitive types: [int], [double], [String], [bool]
/// - [Null]s
/// - [List]s (recursively serializes elements)
/// - [Map]s (recursively serializes keys and values)
/// - [CrystallisMixin] objects (calls their [serialize] method)
/// - Other types result in an [ArgumentError]
dynamic serialize(dynamic value) => switch (value) {
      null => null,
      int() || double() || String() || bool() => value,
      List() => value.map(serialize).toList(),
      Map() => value.map((k, v) => MapEntry(k.toString(), serialize(v))),
      CrystallisMixin() => value.serialize(),
      _ => throw ArgumentError.value(
          value,
          'value',
          'Cannot serialize value of type ${value.runtimeType}',
        ),
    };

/// Basic deserialization function. Handles:
/// - Primitive types: [int], [double], [String], [bool]
/// - [Null]s
/// - [List]s (recursively deserializes elements)
/// - [Map]s (recursively deserializes keys and values)
/// - Other types result in an [ArgumentError]
dynamic deserialize(dynamic value) => switch (value) {
      null => null,
      int() || double() || String() || bool() => value,
      List() => value.map(deserialize).toList(),
      Map() => value.map((k, v) => MapEntry(deserialize(k), deserialize(v))),
      _ => throw ArgumentError.value(
          value,
          'value',
          'Cannot deserialize value of type ${value.runtimeType}',
        ),
    };
