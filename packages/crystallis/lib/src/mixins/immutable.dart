library;

import 'package:crystallis/crystallis.dart';

import 'base.dart';

/// Immutable variant of [CrystallisData].
///
/// Applied to generated data classes when [Crystallise.mutable] is false.
/// Prevents field modification after instantiation.

/// Immutable variant of [CrystallisData].
///
/// Used on generated data classes when [Crystallise.mutable] is false.
/// Prevents field modification after instantiation.
///
/// Example:
/// ```dart
/// @Crystallise(mutable: false)
/// class User {
///   final String name = '';
/// }
///
/// void main() {
///   final user = User();
///   // user.name = 'John'; // Would throw StateError
/// }
/// ```
abstract mixin class ImmutableCrystallisData implements CrystallisData {
  /// Always throws a [StateError] since immutable data classes
  /// cannot be modified.
  @override
  void set<T>(String field, T value) {
    throw StateError(
      'Cannot set field "$field" on immutable data class',
    );
  }

  /// Always throws a [StateError] since immutable data classes
  /// cannot be modified.
  @override
  void setFrom(CrystallisData other) {
    throw StateError(
      'Cannot set fields from another instance on immutable data class',
    );
  }
}
