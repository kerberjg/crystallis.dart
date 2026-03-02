import 'package:analyzer/error/error.dart';

/// {@template crystallis_code}
/// Code for diagnostics produced by the Crystallis plugin.
/// {@endtemplate}
class CrystallisLintCode extends LintCode {
  /// {@macro crystallis_code}
  const CrystallisLintCode({
    required String name,
    required this.description,
    required String problemMessage,
    super.correctionMessage,
    super.uniqueName,
    super.severity = DiagnosticSeverity.INFO,
  }) : super(name, problemMessage);

  /// A human-readable description of the rule that is being violated.
  final String description;
}

/// An enumeration of all the rules that the Crystallis plugin provides. Each rule has a corresponding [CrystallisLintCode]
/// that contains the details of the rule.
enum CrystallisCode {
  /// {@macro mutable_rule}
  mutable(
    CrystallisLintCode(
      name: 'mutable',
      description: 'This rule checks for mutable fields in classes annotated with @Crystallis(mutable: false).',
      problemMessage: 'Classes annotated with @Crystallis(mutable: false) should not have mutable fields.',
      correctionMessage: 'Consider making the field final or using a different annotation setting.',
    ),
  );

  const CrystallisCode(this.code);

  /// The [CrystallisLintCode] associated with this rule. This contains the details of the rule, such as the name,
  /// description, problem message, and correction message.
  final CrystallisLintCode code;
}
