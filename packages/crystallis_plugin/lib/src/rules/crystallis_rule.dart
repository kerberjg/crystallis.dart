import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:crystallis_plugin/src/rules/crystallis_code.dart';
import 'package:meta/meta.dart';

/// An enumeration of all the rules that the Crystallis plugin provides. Each rule has at least one corresponding
/// [CrystallisLintCode] that will be reported when the rule is violated.
enum CrystallisRuleFlag {
  /// {@macro mutability_rule}
  mutability(
    name: 'mutability',
    description:
        'This rule checks for mutable fields in classes annotated with @Crystallise to make sure they align with '
        "whatever 'mutable' value they were defined.",
    lint: false,
  ),

  /// {@macro equals_rule}
  equals(
    name: 'equals',
    description:
        'This rule checks for == operators manually defined in classes annotated with @Crystallise '
        'when equals generation is enabled, as the generator will skip generation in that case.',
  ),

  /// {@macro tostring_rule}
  tostring(
    name: 'tostring',
    description:
        'This rule checks for toString() methods manually defined in classes annotated with @Crystallise '
        'when toString generation is enabled, as the generator will skip generation in that case.',
    lint: false,
  ),

  /// {@macro hashcode_rule}
  hashcode(
    name: 'hashcode',
    description:
        'This rule checks for hashCode getters manually defined in classes annotated with @Crystallise '
        'when hashCode generation is enabled, as the generator will skip generation in that case.',
    lint: false,
  ),

  /// {@macro class_modifier_rule}
  classModifier(
    name: 'class_modifier',
    description:
        'This rule checks for classes annotated with @Crystallise that are sealed, final, or have a private name, '
        'as no subclasses can be generated for them.',
    lint: false,
  );

  const CrystallisRuleFlag({required this.name, required this.description, this.lint = true});

  /// A human-readable name for the rule, used in the insights page and similar.
  final String name;

  /// A human-readable description of the rule that is being violated, used in the insights page and similar.
  final String description;

  /// Whether this rule should be enabled by the user or if it would be enabled regardless of user configuration. This
  /// is useful for rules that are critical to the workings of the package.
  final bool lint;

  @override
  String toString() => name;
}

/// {@template crystallis_rule}
/// A base class for all analysis rules provided by the Crystallis plugin. Each rule checks for a specific violation of
/// the Crystallis annotations and provides a corresponding diagnostic code.
/// {@endtemplate}
abstract class CrystallisRule extends AnalysisRule {
  /// {@macro crystallis_rule}
  CrystallisRule(CrystallisCode code)
    : diagnosticCode = code.code,
      super(name: code.name, description: code.code.description);

  @override
  final CrystallisLintCode diagnosticCode;

  @override
  @mustBeOverridden
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context);
}

/// {@template multi_crystallis_rule}
/// A base class for analysis rules that need to produce multiple diagnostics. This is useful for rules that need to
/// check different but related things.
/// {@endtemplate}
abstract class MutltiCrystallisRule extends MultiAnalysisRule {
  /// {@macro multi_crystallis_rule}
  MutltiCrystallisRule(CrystallisRuleFlag ruleType) : super(name: ruleType.name, description: ruleType.description);

  @override
  List<CrystallisLintCode> get diagnosticCodes => codes.map((c) => c.code).toList();

  /// A list of all the [CrystallisLintCode]s that this rule can report. This is used to register the codes with the
  /// server.
  List<CrystallisCode> get codes;

  @override
  @mustBeOverridden
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context);
}
