import 'package:analyzer/error/error.dart';
import 'package:crystallis_plugin/src/rules/mutable.dart';

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
  /// Checks whether classes annotated with @Crystallis(mutable: false) have any non-final fields.
  mutableField(
    CrystallisLintCode(
      name: MutableRule.baseName,
      description: MutableRule.baseDescription,
      uniqueName: 'crystallis_mutable_field',
      problemMessage: 'Classes annotated with @Crystallis(mutable: false) should not have non-final fields.',
      correctionMessage:
          "Consider making the field final or changing the value for 'mutable' in @Crystallise annotation.",
    ),
  ),

  /// Checks whether classes annotated with @Crystallis(mutable: true) have any final fields.
  immutableField(
    CrystallisLintCode(
      name: MutableRule.baseName,
      description: MutableRule.baseDescription,
      uniqueName: 'crystallis_immutable_field',
      problemMessage: 'Classes annotated with @Crystallis(mutable: true) should not have final fields.',
      correctionMessage:
          "Consider making the field non-final or changing the value for 'mutable' in @Crystallise annotation.",
    ),
  ),

  /// Checks whether classes annotated with @Crystallis(mutable: false) have any non-final fields.
  constConstructor(
    CrystallisLintCode(
      name: MutableRule.baseName,
      description: MutableRule.baseDescription,
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
      name: MutableRule.baseName,
      description: MutableRule.baseDescription,
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
