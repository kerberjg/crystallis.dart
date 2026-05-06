/// Rules enforced by Crystallis, each carrying its base diagnostic message.
enum CrystallisRuleMessage {
  /// Classes annotated with `@Crystallise` cannot be sealed.
  classIsSealed('Classes annotated with @Crystallise cannot be sealed.'),

  /// Classes annotated with `@Crystallise` cannot be final.
  classIsFinal('Classes annotated with @Crystallise cannot be final.'),

  /// Classes annotated with `@Crystallise` cannot have a private name.
  classIsPrivate('Classes annotated with @Crystallise cannot have a private name.'),

  /// Cannot generate `toString()` when it is already defined in the class.
  toStringAlreadyDefined('Cannot generate toString() method: already defined in {0}.'),

  /// Cannot generate `==` operator when it is already defined in the class.
  equalAlreadyDefined('Cannot generate == operator: already defined in {0}.'),

  /// Cannot generate `hashCode` getter when it is already defined in the class.
  hashCodeAlreadyDefined('Cannot generate hashCode getter: already defined in {0}.');

  const CrystallisRuleMessage(this.message);

  /// The base diagnostic message for this rule.
  ///
  /// May contain the `{0}` placeholder; use [format] to substitute it.
  final String message;

  /// Returns [message] with `{0}` replaced by [className].
  String format({required String className}) => message.replaceAll('{0}', className);
}
