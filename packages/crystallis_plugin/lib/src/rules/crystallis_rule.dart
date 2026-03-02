import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:crystallis_plugin/src/rules/crystallis_code.dart';
import 'package:meta/meta.dart';

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
