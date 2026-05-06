import 'package:analyzer/dart/element/element.dart';

import 'crystallis_rule_message.dart';

/// An enforcerer for the rules of the Crystallis Generator.
enum CrystallisEnforcer {
  /// The singleton instance of the CrystallisEnforcer.
  instance;

  /// Const constructor for the CrystallisEnforcer class.
  const CrystallisEnforcer();

  /// If class modifiers are valid for a class annotated with `@Crystallise`, returns `null`. Otherwise, returns an
  /// error message describing the issue.
  String? classModifiersAreValid(ClassElement element) {
    if (element.isSealed) {
      return CrystallisRuleMessage.classIsSealed.message;
    }
    if (element.isFinal) {
      return CrystallisRuleMessage.classIsFinal.message;
    }
    if (element.isPrivate) {
      return CrystallisRuleMessage.classIsPrivate.message;
    }
    return null;
  }

  /// If `toString` method can be generated for the data class, returns `null`. Otherwise, returns an error message
  /// describing the issue.
  String? toStringIsValid(ClassElement element) {
    if (element.getMethod('toString') case MethodElement(isStatic: false)) {
      return CrystallisRuleMessage.toStringAlreadyDefined.format(className: element.displayName);
    }
    return null;
  }

  /// If `==` (equals) operator can be generated for the data class, returns `null`. Otherwise, returns an error message
  /// describing the issue.
  String? equalIsValid(ClassElement element) {
    if (element.getMethod('==') case MethodElement(isStatic: false)) {
      return CrystallisRuleMessage.equalAlreadyDefined.format(className: element.displayName);
    }
    return null;
  }

  /// If `hashCode` getter can be generated for the data class, returns `null`. Otherwise, returns an error message
  /// describing the issue.
  String? hashCodeIsValid(ClassElement element) {
    if (element.getGetter('hashCode') case GetterElement(isStatic: false)) {
      return CrystallisRuleMessage.hashCodeAlreadyDefined.format(className: element.displayName);
    }
    return null;
  }
}
