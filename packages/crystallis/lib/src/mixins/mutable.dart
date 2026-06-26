library;

import 'package:crystallis/crystallis.dart';

import 'base.dart';

/// Mutable variant of [CrystallisData].
///
/// Applied to generated data classes when [Crystallise.mutable] is true.
/// Allows field modification after instantiation.

/// Mutable variant of [CrystallisData].
///
/// Used on generated data classes when [Crystallise.mutable] is true.
/// Allows field modification after instantiation.
///
/// Example:
/// ```dart
/// @Crystallise(mutable: true)
/// class User {
///   String name = '';
/// }
///
/// void main() {
///   final user = User();
///   user.name = 'John'; // Allowed
/// }
/// ```
abstract mixin class MutableCrystallisData implements CrystallisData {
  @override
  void setFrom(CrystallisData other) {
    // skip this both this and other are of the same type
    final bool isSameType = this.runtimeType == other.runtimeType;

    for (final name in metadata.keys) {
      if (!isSameType) {
        final thisMeta = metadata[name]!;
        final otherMeta = other.metadata[name];

        // dart format off
        if (
          otherMeta == null // missing
          || otherMeta.type != thisMeta .type // type-mismatched fields
          || !thisMeta.mutable // this field is immutable
        ) {
          continue;
        }
        // dart format on
      }

      final value = other.get(name);

      // skip null values
      if (value != null) {
        set(name, value);
      }
    }
  }
}
