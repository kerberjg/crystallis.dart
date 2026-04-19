import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:crystallis_plugin/src/rules/crystallis_rule.dart';
import 'package:crystallis_plugin/src/rules/hashcode.dart';
import 'package:crystallis_plugin/src/rules/equals.dart';
import 'package:crystallis_plugin/src/rules/mutability.dart';
import 'package:crystallis_plugin/src/rules/tostring.dart';

/// A mixin to handle the integration of the declared rules into the plugin.
mixin RulesMixin {
  /// A list of all the rules that the plugin provides. This is used to register the rules with the server.
  List<AbstractAnalysisRule> get rules => [
    for (var ruleFlag in CrystallisRuleFlag.values)
      switch (ruleFlag) {
        .mutability => MutabilityRule(),
        .equals => EqualsRule(),
        .tostring => ToStringRule(),
        .hashcode => HashCodeRule(),
      },
  ];

  /// Registers all the rules this plugin provides.
  void registerRules(void Function(AbstractAnalysisRule) register) {
    for (var rule in rules) {
      register(rule);
    }
  }
}
