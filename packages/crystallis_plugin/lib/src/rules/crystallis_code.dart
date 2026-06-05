import 'dart:math';

import 'package:analyzer/error/error.dart';
import 'package:crystallis_generator/src/crystallis_rule_message.dart'; // ignore: implementation_imports owned package
import 'package:crystallis_plugin/src/rules/crystallis_rule.dart';

/// An enumeration of all the specfic codes that the crystallis_plugin can report on rules. This is a wrapper on
/// [CrystallisLintCode] so we can have them constants.
///
/// This is needed because the server internally checks for the same instance of `LintCode`s, so we must ensure these
/// are constants and not created on the fly.
enum CrystallisCode {
  /// Checks whether classes annotated with @Crystallise(mutable: false) have any non-final fields.
  mutableField(
    CrystallisLintCode(
      ruleFlag: .mutability,
      severity: .ERROR,
      uniqueName: 'crystallis_mutable_field',
      problemMessage: 'Classes annotated with @Crystallise(mutable: false) should not have non-final fields.',
      correctionMessage:
          "Consider making the field final or changing the value for 'mutable' in @Crystallise annotation.",
    ),
  ),

  /// Checks whether classes annotated with @Crystallise(mutable: true) have any final fields.
  immutableField(
    CrystallisLintCode(
      ruleFlag: .mutability,
      severity: .ERROR,
      uniqueName: 'crystallis_immutable_field',
      problemMessage: 'Classes annotated with @Crystallise(mutable: true) should not have final fields.',
      correctionMessage:
          "Consider making the field non-final or changing the value for 'mutable' in @Crystallise annotation.",
    ),
  ),

  /// Checks whether classes annotated with @Crystallise(mutable: false) have any non-final fields.
  constConstructor(
    CrystallisLintCode(
      ruleFlag: .mutability,
      severity: .ERROR,
      uniqueName: 'crystallis_const_constructor',
      problemMessage:
          "Classes annotated with @Crystallise(mutable: true) should not have a 'const' default constructor.",
      correctionMessage:
          "Consider removing 'const' from the constructor declaration or changing the value for 'mutable' in "
          '@Crystallise annotation.',
    ),
  ),

  /// Checks whether classes annotated with @Crystallise(mutable: true) have any final fields.
  nonConstConstructor(
    CrystallisLintCode(
      ruleFlag: .mutability,
      severity: .ERROR,
      uniqueName: 'crystallis_non_const_constructor',
      problemMessage:
          "Classes annotated with @Crystallise(mutable: false) should not have a non-'const' default constructor.",
      correctionMessage:
          "Consider making the constructor 'const' or changing the value for 'mutable' in @Crystallise annotation.",
    ),
  ),

  /// Checks whether a class annotated with @Crystallise(equals: true) already defines a == operator,
  /// which would prevent the generator from generating one.
  equalsDefined(
    CrystallisLintCode.generatorMessages(
      ruleFlag: .equals,
      severity: .WARNING,
      uniqueName: 'crystallis_equals_defined',
      problemMessage: .equalAlreadyDefined,
      correctionMessage: "Consider removing the == operator or setting 'equals: false' in the @Crystallise annotation.",
    ),
  ),

  /// Checks whether a class annotated with @Crystallise(toString: true) already defines a toString() method,
  /// which would prevent the generator from generating one.
  toStringDefined(
    CrystallisLintCode.generatorMessages(
      ruleFlag: .tostring,
      severity: .WARNING,
      uniqueName: 'crystallis_tostring_defined',
      problemMessage: .toStringAlreadyDefined,
      correctionMessage:
          "Consider removing the toString() method or setting 'toString: false' in the @Crystallise annotation.",
    ),
  ),

  /// Checks whether a class annotated with @Crystallise(hashCode: true) already defines a hashCode getter,
  /// which would prevent the generator from generating one.
  hashCodeDefined(
    CrystallisLintCode.generatorMessages(
      ruleFlag: .hashcode,
      severity: .WARNING,
      uniqueName: 'crystallis_hashcode_defined',
      problemMessage: .hashCodeAlreadyDefined,
      correctionMessage:
          "Consider removing the hashCode getter or setting 'hashCode: false' in the @Crystallise annotation.",
    ),
  );

  const CrystallisCode(this.code);

  /// The [CrystallisLintCode] associated with this rule. This contains the details of the rule, such as the name,
  /// description, problem message, and correction message.
  final CrystallisLintCode code;
}

/// {@template crystallis_code}
/// Code for diagnostics produced by the Crystallis plugin.
/// {@endtemplate}
class CrystallisLintCode implements LintCode {
  /// Regular expression for identifying positional arguments in error messages.
  static final RegExp _positionalArgumentRegExp = RegExp(r'\{(\d+)\}');

  /// {@macro crystallis_code}
  const CrystallisLintCode({
    required this.ruleFlag,
    required String problemMessage,
    this.correctionMessage,
    this.severity = .INFO,
    this.type = .LINT,
    String? uniqueName,
  }) : url = null,
       isUnresolvedIdentifier = false,
       hasPublishedDocs = false,
       isIgnorable = true,
       _problemMessage = problemMessage, // TODO(FMorschel): Make use of private named parameters when possible.
       _problemMessageEnum = null,
       uniqueName = uniqueName ?? 'CrystallisLintCode.$ruleFlag';

  /// {@macro crystallis_code}
  const CrystallisLintCode.generatorMessages({
    required this.ruleFlag,
    required CrystallisRuleMessage problemMessage,
    this.correctionMessage,
    this.severity = .INFO,
    this.type = .LINT,
    String? uniqueName,
  }) : url = null,
       isUnresolvedIdentifier = false,
       hasPublishedDocs = false,
       isIgnorable = true,
       _problemMessage = null,
       _problemMessageEnum = problemMessage,
       uniqueName = uniqueName ?? 'CrystallisLintCode.$ruleFlag';

  /// The rule type this code is associated with.
  final CrystallisRuleFlag ruleFlag;

  @override
  @Deprecated('Please use lowerCaseName')
  String get name => type.name;

  /// A human-readable description of the rule that is being violated, used in the insights page and similar.
  String get description => ruleFlag.description;

  @override
  final String? correctionMessage;

  @override
  @Deprecated("Use 'severity' instead")
  DiagnosticSeverity get errorSeverity => severity;

  @override
  final bool hasPublishedDocs;

  @override
  final bool isIgnorable;

  @override
  final bool isUnresolvedIdentifier;

  @override
  String get lowerCaseName => name.toLowerCase();

  @override
  String get lowerCaseUniqueName => uniqueName.toLowerCase();

  @override
  int get numParameters {
    int result = 0;
    for (String s in [problemMessage, ?correctionMessage]) {
      for (RegExpMatch match in _positionalArgumentRegExp.allMatches(s)) {
        result = max(result, int.parse(match.group(1)!) + 1);
      }
    }
    return result;
  }

  @override
  String get problemMessage => _problemMessage ?? _problemMessageEnum!.message;

  final String? _problemMessage;
  final CrystallisRuleMessage? _problemMessageEnum;

  @override
  final DiagnosticSeverity severity;

  @override
  final DiagnosticType type;

  @override
  @Deprecated('Please use lowerCaseUniqueName')
  final String uniqueName;

  @override
  final String? url;

  @override
  String toString() => 'CrystallisLintCode.$lowerCaseUniqueName';
}
