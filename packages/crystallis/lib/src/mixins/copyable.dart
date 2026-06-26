import 'package:crystallis/crystallis.dart';

import 'base.dart';

/// Mixin class for data classes that support copy methods (e.g. [copyWith]).
///
/// Applied to classes generated with [Crystallise.enableCopyWith] set to true.
///
/// Example:
/// ```dart
/// @Crystallise()
/// class User {
///   String name = '';
///   int age = 0;
/// }
///
/// void main() {
///   final user = User()..name = 'John'..age = 25;
///   final older = user.copyWith(age: 26);
///   print('${user.age}, ${older.age}'); // 25, 26
/// }
/// ```
abstract mixin class CopyableCrystallisData<T extends CrystallisData> implements CrystallisData {
  /// Creates a copy of this object, with the same values for all fields.
  ///
  /// If [Crystallise.useDeepCopy] is true, performs a deep copy of all fields
  /// that are collections or other [CrystallisData] objects.
  /// Otherwise, performs a shallow copy (i.e. just copies references) for all fields.
  ///
  /// See [Crystallise.enableCopyWith] for how to enable/disable copy methods.
  T Function() get copyWith;

  /// Creates a copy of this object, with the same values for all fields except those provided in [other].
  ///
  /// Fields from [other] that are missing, null, or of the wrong type are
  /// ignored and retain their original value in the copy.
  ///
  /// If [Crystallise.useDeepCopy] is true, performs a deep copy of all fields
  /// that are collections or other [CrystallisData] objects.
  /// Otherwise, performs a shallow copy (i.e. just copies references) for all fields.
  T copyFrom(CrystallisData other);
}
