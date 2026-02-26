import 'package:crystallis/crystallis.dart';

/// Abstract base class for custom serializers. See [Serializer] for details.
abstract class Serializer<I, O> {
  /// Creates a [Serializer]
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

/// Specifies a custom serializer/deserializer annotation for a field
/// Converts between type [I] (the field type) and type [U] (the serialized type)
class CustomSerializer<I, O> extends Serializer<I, O> {
  /// Function that converts from type [I] to type [O]
  final O Function(I value) _serialize;

  /// Function that converts from type [O] to type [I]
  final I Function(O value) _deserialize;

  /// Creates a [Serializer] with the given [serialize] and [deserialize] functions
  const CustomSerializer({
    required O Function(I value) serialize,
    required I Function(O value) deserialize,
  })  : _serialize = serialize,
        _deserialize = deserialize;

  @override
  O serialize(I value) => _serialize(value);
  @override
  I deserialize(O value) => _deserialize(value);
}

/// Default [Serializer] that handles basic types and nested [CrystallisMixin]..
/// See [serialize] and [deserialize] functions for details.
class DefaultSerializer<T> extends Serializer<T, Object?> {
  /// Creates a [DefaultSerializer].
  const DefaultSerializer();

  @override
  Object? serialize(T value) => serializeValue(value);

  @override
  T deserialize(Object? value) => deserializeValue<T>(value)!;
}

/// Basic serialization function. Handles:
/// - Primitive types: [int], [double], [String], [bool]
/// - [Null]s
/// - [List]s (recursively serializes elements)
/// - [Map]s (recursively serializes keys and values)
/// - [CrystallisMixin] objects (calls their [serialize] method)
/// - Other types result in an [ArgumentError]
dynamic serializeValue(dynamic value) => switch (value) {
      null => null,
      int() || double() || String() || bool() => value,
      List() => value.map(serializeValue).toList(),
      Map() => value.map((k, v) => MapEntry(k.toString(), serializeValue(v))),
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
T? _fallbackDeserializeValue<T>(dynamic value) => switch (value) {
      null => null,
      int() || double() || String() || bool() => value as T,
      List() => value.map(_fallbackDeserializeValue).toList() as T,
      Map() => value.map((k, v) => MapEntry(_fallbackDeserializeValue(k)!, _fallbackDeserializeValue(v))) as T,
      _ => throw ArgumentError.value(
          value,
          'value',
          'Cannot deserialize value of type ${value.runtimeType} to type $T',
        ),
    };

/// A [Serializer] that uses [serializeValue] and [_fallbackDeserializeValue]
/// for serialization and deserialization.
const fallbackDeserializer = CustomSerializer(
  serialize: serializeValue,
  deserialize: _fallbackDeserializeValue,
);

/// List of supported primitive types for serialization/deserialization
const supportedPrimitiveTypes = {int, double, String, bool, Null, List, Map};

/// Basic deserialization function. Handles:
/// - Primitive types: [int], [double], [String], [bool]
/// - [Null]s
/// - [List]s (recursively deserializes elements)
/// - [Map]s (recursively deserializes keys and values)
/// - Other types result in an [ArgumentError]
T deserializeValue<T>(dynamic value) {
  if (!(supportedPrimitiveTypes.contains(value.runtimeType) //
      ||
      value is List ||
      value is Map ||
      value is Set)) {
    throw ArgumentError.value(
      value.runtimeType,
      'type',
      'Unsupported input type for deserialization: ${value.runtimeType}',
    );
  }

  if (value is T) {
    return value;
  }

  if (T == Null || value == null) {
    return null as T;
  } else if (T == int) {
    return int.parse(value) as T;
  } else if (T == double) {
    return double.parse(value) as T;
  } else if (T == String) {
    return value.toString() as T;
  } else if (T == bool) {
    return bool.parse(value) as T;
  } else if (T == List) {
    return (value as List).map(_fallbackDeserializeValue).toList() as T;
  } else if (T == Map) {
    return (value as Map).map((k, v) => MapEntry(_fallbackDeserializeValue(k)!, _fallbackDeserializeValue(v))) as T;
  }

  throw ArgumentError.value(
    value,
    'value',
    'Cannot deserialize value of type ${value.runtimeType} to type $T',
  );
}

/// Deserializes a [Map] by its respective key and value types
Map<K, V?> deserializeMap<K, V>(Map<dynamic, dynamic> map) {
  return map.map((k, v) => MapEntry(deserializeValue<K>(k), deserializeValue<V>(v)));
}

/// Serializes a [Map] to a JSON-compatible [Map<String, dynamic>]
/// by converting keys to strings and recursively serializing values
Map<String, V?> serializeMap<V>(Map<dynamic, V> map) {
  return map.map((k, v) => MapEntry(k.toString(), serializeValue(v)));
}

/// A [Serializer] for maps with keys of type [K] and values of type [V].
class MapSerializer<K, V> extends Serializer<Map<K, V?>, Map<String, dynamic>> {
  /// Creates a [MapSerializer].
  const MapSerializer();

  @override
  Map<String, dynamic> serialize(Map<K, V?> value) => serializeMap(value);

  @override
  Map<K, V?> deserialize(Map<String, dynamic> value) => deserializeMap(value);
}
