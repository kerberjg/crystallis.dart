import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';
import 'package:crystallis_plugin/src/rules/crystallis_rule.dart';

import 'crystallis_dependency.dart';

abstract class MutltiCrystallisRuleTest<TCrystallisCode extends CrystallisCodeMixin> extends AnalysisRuleTest
    with CrystallisDependency {
  @override
  MutltiCrystallisRule<TCrystallisCode> get rule;

  @override
  Future<void> setUp() async {
    await addCrystallisDependency();
    super.setUp();
  }

  ExpectedDiagnostic code(
    TCrystallisCode code,
    int offset,
    int length, {
    List<Pattern> messageContainsAll = const [],
    Pattern? correctionContains,
    List<ExpectedContextMessage>? contextMessages,
  }) => error(
    code.code,
    offset,
    length,
    messageContainsAll: messageContainsAll,
    correctionContains: correctionContains,
    contextMessages: contextMessages,
  );
}
