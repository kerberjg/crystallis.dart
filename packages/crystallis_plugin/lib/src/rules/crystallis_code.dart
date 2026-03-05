import 'dart:math';

import 'package:analyzer/error/error.dart';
import 'package:crystallis_plugin/src/rules/crystallis_rule.dart';

/// An enumeration of all the specfic codes that the crystallis_plugin can report on rules. This is a wrapper on
/// [CrystalliseLintCode] so we can have them constants.
///
/// This is needed because the server internally checks for the same instance of `LintCode`s, so we must ensure these
/// are constants and not created on the fly.
enum CrystalliseCode {
  /// Checks whether classes annotated with @Crystallise(mutable: false) have any non-final fields.
  mutableField(
    CrystalliseLintCode(
      ruleType: CrystallisRuleType.mutability,
      uniqueName: 'crystallis_mutable_field',
      problemMessage: 'Classes annotated with @Crystallise(mutable: false) should not have non-final fields.',
      correctionMessage:
          "Consider making the field final or changing the value for 'mutable' in @Crystallise annotation.",
    ),
  ),

  /// Checks whether classes annotated with @Crystallise(mutable: true) have any final fields.
  immutableField(
    CrystalliseLintCode(
      ruleType: CrystallisRuleType.mutability,
      uniqueName: 'crystallis_immutable_field',
      problemMessage: 'Classes annotated with @Crystallise(mutable: true) should not have final fields.',
      correctionMessage:
          "Consider making the field non-final or changing the value for 'mutable' in @Crystallise annotation.",
    ),
  ),

  /// Checks whether classes annotated with @Crystallise(mutable: false) have any non-final fields.
  constConstructor(
    CrystalliseLintCode(
      ruleType: CrystallisRuleType.mutability,
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
    CrystalliseLintCode(
      ruleType: CrystallisRuleType.mutability,
      uniqueName: 'crystallis_non_const_constructor',
      problemMessage:
          "Classes annotated with @Crystallise(mutable: false) should not have a non-'const' default constructor.",
      correctionMessage:
          "Consider making the constructor 'const' or changing the value for 'mutable' in @Crystallise annotation.",
    ),
  );

  const CrystalliseCode(this.code);

  /// The [CrystalliseLintCode] associated with this rule. This contains the details of the rule, such as the name,
  /// description, problem message, and correction message.
  final CrystalliseLintCode code;
}

/// {@template crystallis_code}
/// Code for diagnostics produced by the Crystallis plugin.
/// {@endtemplate}
class CrystalliseLintCode implements LintCode {
  /// Regular expression for identifying positional arguments in error messages.
  static final RegExp _positionalArgumentRegExp = RegExp(r'\{(\d+)\}');

  /// {@macro crystallis_code}
  const CrystalliseLintCode({
    required this.ruleType,
    required this.problemMessage,
    this.correctionMessage,
    this.severity = .INFO,
    this.type = .LINT,
    String? uniqueName,
  }) : url = null,
       isUnresolvedIdentifier = false,
       hasPublishedDocs = false,
       isIgnorable = true,
       uniqueName = uniqueName ?? 'CrystallisLintCode.$ruleType';

  /// The rule type this code is associated with.
  final CrystallisRuleType ruleType;

  @override
  @Deprecated('Please use lowerCaseName')
  String get name => type.name;

  /// A human-readable description of the rule that is being violated, used in the insights page and similar.
  String get description => ruleType.description;

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
  final String problemMessage;

  @override
  final DiagnosticSeverity severity;

  @override
  final DiagnosticType type;

  @override
  @Deprecated('Please use lowerCaseUniqueName')
  final String uniqueName;

  @override
  final String? url;
}
