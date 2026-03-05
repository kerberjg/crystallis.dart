import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:crystallis_plugin/src/rules/crystallis_code.dart';
import 'package:meta/meta.dart';

/// An enumeration of all the rules that the Crystallis plugin provides. Each rule has at least one corresponding
/// [CrystalliseLintCode] that will be reported when the rule is violated.
enum CrystallisRuleType {
  /// {@macro mutability_rule}
  mutability(
    name: 'mutability',
    description:
        'This rule checks for mutable fields in classes annotated with @Crystallise to make sure they align with '
        "whatever 'mutable' value they were defined.",
  );

  const CrystallisRuleType({required this.name, required this.description});

  /// A human-readable name for the rule, used in the insights page and similar.
  final String name;

  /// A human-readable description of the rule that is being violated, used in the insights page and similar.
  final String description;

  @override
  String toString() => name;
}

/// {@template crystallis_rule}
/// A base class for all analysis rules provided by the Crystallis plugin. Each rule checks for a specific violation of
/// the Crystallis annotations and provides a corresponding diagnostic code.
/// {@endtemplate}
abstract class CrystallisRule extends AnalysisRule {
  /// {@macro crystallis_rule}
  CrystallisRule(CrystalliseCode code)
    : diagnosticCode = code.code,
      super(name: code.name, description: code.code.description);

  @override
  final CrystalliseLintCode diagnosticCode;

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
  MutltiCrystallisRule(CrystallisRuleType ruleType) : super(name: ruleType.name, description: ruleType.description);

  @override
  List<CrystalliseLintCode> get diagnosticCodes;

  @override
  @mustBeOverridden
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context);
}
