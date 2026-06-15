/// Abstract base class for custom serializers.
/// See [Serializable] and [FieldMetadata.serializer] for details.
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
/// Converts between type [I] (the field type) and type [O] (the serialized type)
class Serializable<I, O> extends Serializer<I, O> {
  /// Function that converts from type [I] to type [O]
  final O Function(I value) _serialize;

  /// Function that converts from type [O] to type [I]
  final I Function(O value) _deserialize;

  /// Creates a [Serializable] with the given [serialize] and [deserialize] functions
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