import 'package:meta/meta.dart';

import '../api/serializer.dart';
import 'mixins/base.dart';

/// List of supported primitive types for serialization/deserialization
const Set<Type> kSupportedPrimitiveTypes = {int, double, String, bool, Null};

/// Basic serialization function. Handles:
/// - Primitive types: [int], [double], [String], [bool]
/// - [Null]s
/// - [List]s (recursively serializes elements)
/// - [Map]s (recursively serializes keys and values)
/// - [CrystallisData] objects (calls their [serialize] method)
/// - Other types result in an [ArgumentError]
dynamic serializeValue(dynamic value) => switch (value) {
  null => null,
  int() || double() || String() || bool() => value,
  List() => value.map(serializeValue).toList(),
  Map() => value.map((k, v) => MapEntry(k.toString(), serializeValue(v))),
  CrystallisData() => value.serialize(),
  _ => throw ArgumentError.value(
    value,
    'value',
    'Cannot serialize value of type ${value.runtimeType}',
  ),
};

/// Serializes a [Map] to a JSON-compatible [Map<String, dynamic>]
/// by converting keys to strings and recursively serializing values
Map<String, V?> serializeMap<V>(Map<dynamic, V> map) => //
    map.map((k, v) => MapEntry(k.toString(), serializeValue(v)));

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
  Map() => value.map((k, v) => MapEntry(k.toString(), _fallbackDeserializeValue(v))) as T,
  _ => throw ArgumentError.value(
    value,
    'value',
    'Cannot deserialize value of type ${value.runtimeType} to type $T',
  ),
};

/// test-only alias for [_fallbackDeserializeValue]
@visibleForTesting
T? fallbackDeserializeValue<T>(dynamic value) => _fallbackDeserializeValue<T>(value);

/// Basic deserialization function. Handles:
/// - Primitive types: [int], [double], [String], [bool]
/// - [Null]s
/// - [List]s (recursively deserializes elements)
/// - [Map]s (recursively deserializes keys and values)
/// - Other types result in an [ArgumentError]
T deserializeValue<T>(dynamic value) {
  if (!(kSupportedPrimitiveTypes.contains(value.runtimeType) || //
      (value is List || value is Map || value is Set) //
      )) {
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
  } else {
    // deserialize nullables
    if (isNullable<T>()) {
      if (isNullableSelf<int, T>()) {
        return int.tryParse(value) as T;
      } else if (isNullableSelf<double, T>()) {
        return double.tryParse(value) as T;
      } else if (isNullableSelf<String, T>()) {
        return value.toString() as T;
      } else if (isNullableSelf<bool, T>()) {
        return bool.tryParse(value) as T;
      }
    }
    // deserialize non-nullables
    else {
      if (T == int) {
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
    }
  }

  throw ArgumentError.value(
    value,
    'value',
    'Cannot deserialize value of type ${value.runtimeType} to type $T',
  );
}

/// Returns whether the given type [T] is a nullable of the given non-nullable type [C].
@pragma("vm:always-consider-inlining")
bool isNullableSelf<C, T>() => isNullable<T>() && <C?>[] is List<T>;

/// Returns whether the given type [T] is a nullable of the given non-nullable type [C].
@pragma("vm:always-consider-inlining")
bool isNullable<T>() => null is T;

/// Deserializes a [Map] by its respective key and value types
Map<K, V?> deserializeMap<K, V>(Map<dynamic, dynamic> map) {
  // ignore: null_check_on_nullable_type_parameter
  return map.map(
    (k, v) => MapEntry(
      k is String
          ? deserializeValue<K>(k)!
          : throw ArgumentError.value(k, 'key', 'Map keys must be strings for deserialization to type $K'),
      deserializeValue<V>(v),
    ),
  );
}

/// Default [Serializer] that handles basic types and nested [CrystallisData]..
/// See [serialize] and [deserialize] functions for details.
class DefaultSerializer<T> extends Serializer<T, Object?> {
  /// Creates a [DefaultSerializer].
  const DefaultSerializer();

  @override
  Object? serialize(T value) => serializeValue(value);

  @override
  T deserialize(Object? value) => deserializeValue<T>(value)!;
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

/// A [Serializer] that uses [serializeValue] and [_fallbackDeserializeValue]
/// for serialization and deserialization.
const fallbackSerializer = Serializable(
  serialize: serializeValue,
  deserialize: _fallbackDeserializeValue,
);