import 'package:analyzer/dart/element/element.dart';

/// A class that enforces the rules of the Crystallis Generator.
class CrystallisEnforcer {
  /// Const constructor for the CrystallisEnforcer class.
  const CrystallisEnforcer._();

  /// The singleton instance of the CrystallisEnforcer class.
  static const instance = CrystallisEnforcer._();

  /// If class modifiers are valid for a class annotated with `@Crystallise`, returns `null`. Otherwise, returns an
  /// error message describing the issue.
  String? classModifiersAreValid(ClassElement element) {
    if (element.isSealed) {
      return 'Classes annotated with @Crystallise cannot be sealed.';
    }
    if (element.isFinal) {
      return 'Classes annotated with @Crystallise cannot be final.';
    }
    if (element.isPrivate) {
      return 'Classes annotated with @Crystallise cannot have a private name.';
    }
    return null;
  }

  /// If `toString` method can be generated for the data class, returns `null`. Otherwise, returns an error message
  /// describing the issue.
  String? toStringIsValid(ClassElement element) {
    if (element.getMethod('toString') case MethodElement(isStatic: false)) {
      return 'Cannot generate toString() method: already defined in ${element.displayName}.';
    }
    return null;
  }

  /// If `==` (equals) operator can be generated for the data class, returns `null`. Otherwise, returns an error message
  /// describing the issue.
  String? equalIsValid(ClassElement element) {
    if (element.getMethod('==') case MethodElement(isStatic: false)) {
      return 'Cannot generate == operator: already defined in ${element.displayName}.';
    }
    return null;
  }

  /// If `hashCode` getter can be generated for the data class, returns `null`. Otherwise, returns an error message
  /// describing the issue.
  String? hashCodeIsValid(ClassElement element) {
    if (element.getGetter('hashCode') case GetterElement(isStatic: false)) {
      return 'Cannot generate hashCode getter: already defined in ${element.displayName}.';
    }
    return null;
  }
}
