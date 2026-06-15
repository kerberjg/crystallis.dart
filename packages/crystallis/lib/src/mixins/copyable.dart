import 'package:crystallis/crystallis.dart';

import 'base.dart';

/// Mixin class for data classes that support copy methods (e.g. [copyWith]).
/// Applied to classes generated with [Crystallise] when [enableCopyWith] is true
abstract mixin class CopyableCrystallisData<T extends CrystallisData> implements CrystallisData {
  /// Creates a copy of this object, with the same values for all fields.
  /// If [Crystallise.useDeepCopy] is true, performs a deep copy of all fields that are collections or other [CrystallisData] objects.
  /// Otherwise, performs a shallow copy (i.e. just copies references) for all fields.
  T Function() get copyWith;

  /// Creates a copy of this object, with the same values for all fields except those provided in [other].
  /// Fields from [other] that are missing, null, or of the wrong type are ignored and retain their original value in the copy.
  /// If [Crystallise.useDeepCopy] is true, performs a deep copy of all fields that are collections or other [CrystallisData] objects.
  /// Otherwise, performs a shallow copy (i.e. just copies references) for all fields.
  T copyFrom(CrystallisData other);
}