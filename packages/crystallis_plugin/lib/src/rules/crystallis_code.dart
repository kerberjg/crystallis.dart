import 'dart:math';

import 'package:analyzer/error/error.dart';
import 'package:crystallis_plugin/src/rules/crystallis_rule.dart';

/// An enumeration of all the rules that the Crystallis plugin provides. Each rule has a corresponding
/// [CrystallisLintCode] that contains the details of the rule.
///
/// This is needed because the server internally checks for the same instance of `LintCode`s, so we must ensure these
/// are constants and not created on the fly.
enum CrystallisCode {
  /// Checks whether classes annotated with @Crystallis(mutable: false) have any non-final fields.
  mutableField(
    CrystallisLintCode(
      ruleType: CrystallisRuleType.mutable,
      uniqueName: 'crystallis_mutable_field',
      problemMessage: 'Classes annotated with @Crystallis(mutable: false) should not have non-final fields.',
      correctionMessage:
          "Consider making the field final or changing the value for 'mutable' in @Crystallise annotation.",
    ),
  ),

  /// Checks whether classes annotated with @Crystallis(mutable: true) have any final fields.
  immutableField(
    CrystallisLintCode(
      ruleType: CrystallisRuleType.mutable,
      uniqueName: 'crystallis_immutable_field',
      problemMessage: 'Classes annotated with @Crystallis(mutable: true) should not have final fields.',
      correctionMessage:
          "Consider making the field non-final or changing the value for 'mutable' in @Crystallise annotation.",
    ),
  ),

  /// Checks whether classes annotated with @Crystallis(mutable: false) have any non-final fields.
  constConstructor(
    CrystallisLintCode(
      ruleType: CrystallisRuleType.mutable,
      uniqueName: 'crystallis_const_constructor',
      problemMessage:
          "Classes annotated with @Crystallis(mutable: true) should not have a 'const' default constructor.",
      correctionMessage:
          "Consider removing 'const' from the constructor declaration or changing the value for 'mutable' in "
          '@Crystallise annotation.',
    ),
  ),

  /// Checks whether classes annotated with @Crystallis(mutable: true) have any final fields.
  nonConstConstructor(
    CrystallisLintCode(
      ruleType: CrystallisRuleType.mutable,
      uniqueName: 'crystallis_non_const_constructor',
      problemMessage:
          "Classes annotated with @Crystallis(mutable: false) should not have a non-'const' default constructor.",
      correctionMessage:
          "Consider making the constructor 'const' or changing the value for 'mutable' in @Crystallise annotation.",
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
  @Deprecated("Use 'diagnosticSeverity' instead")
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
