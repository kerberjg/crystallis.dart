import 'package:meta/meta.dart';
import '../api/serializer.dart';

/// Singleton for managing the global Crystallis configuration.
///
/// Use this to register custom [Serializer]s for specific types
/// or configure other global options.
///
/// Example:
/// ```dart
/// import 'package:crystallis/crystallis.dart';
///
/// Crystallis.i.registerSerializer<MyType>(MyTypeSerializer());
/// ```
class Crystallis {
  /*
   *  Singleton accessors
   */
  /// Private constructor
  Crystallis._internal();

  /// Singleton instance
  static final Crystallis i = Crystallis._internal();

  /// Constructor for testing purposes (do not use in production code)
  @visibleForTesting
  Crystallis.testConstructor();

  /*
   *  Custom serializers
   */

  /// Custom serializer registry
  @visibleForTesting
  @protected
  final Map<Type, Serializer> serializers = {};

  /// Returns the registered [Serializer] for type [T], or `null` if none is registered.
  Serializer<T, dynamic>? getSerializer<T>() {
    return serializers[T] as Serializer<T, dynamic>?;
  }

  /// Returns the registered [Serializer] for type [t], or `null` if none is registered.
  Serializer? getSerializerForType(Type t) {
    return serializers[t];
  }

  /// Registers a custom [Serializer] for type [T].
  void registerSerializer<T>(Serializer<T, dynamic> serializer) {
    serializers[T] = serializer;
  }

  /// Registers a custom [Serializer] for type [t].
  void registerSerializerForType(Type t, Serializer serializer) {
    serializers[t] = serializer;
  }

  /// Unregisters the custom [Serializer] for type [T].
  void unregisterSerializer<T>() {
    serializers.remove(T);
  }

  /// Unregisters the custom [Serializer] for type [t].
  void unregisterSerializerForType(Type t) {
    serializers.remove(t);
  }

  /// Resets the serializer registry.
  void resetSerializers() {
    serializers.clear();
  }

  /*
   *  Utils
   */

  /// Resets the entire Crystallis configuration.
  void reset() {
    resetSerializers();
  }
}
