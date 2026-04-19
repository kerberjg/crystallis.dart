import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:crystallis_plugin/src/rules/class_modifier.dart';
import 'package:crystallis_plugin/src/rules/crystallis_code.dart';
import 'package:essential_lints_annotations/essential_lints_annotations.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/crystallis_dependency.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ClassModifierTest);
  });
}

@reflectiveTest
@SortingMembers({.method(#setUp), .methods}, alphabetizeSortedMembers: true, linesAroundSortedMembers: 1)
class ClassModifierTest extends AnalysisRuleTest with CrystallisDependency {
  @override
  Future<void> setUp() async {
    rule = ClassModifierRule();
    await addCrystallisDependency();
    super.setUp();
  }

  Future<void> test_final() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise()
final class MyClass {
  const MyClass();
  final int field = 0;
}
''',
      [error(CrystallisCode.unsupportedClassModifier.code, 46, 14)],
    );
  }

  Future<void> test_normal() async {
    await assertNoDiagnostics('''
import 'package:crystallis/crystallis.dart';

@Crystallise()
class MyClass {
  const MyClass();
  final int field = 0;
}
''');
  }

  Future<void> test_notAnnotated() async {
    await assertNoDiagnostics('''
sealed class MyClass {
  const MyClass();
  final int field = 0;
}
''');
  }

  Future<void> test_private() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise()
class _MyClass {
  const _MyClass();
  final int field = 0;
}
''',
      [error(CrystallisCode.unsupportedClassModifier.code, 46, 14)],
    );
  }

  Future<void> test_sealed() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise()
sealed class MyClass {
  const MyClass();
  final int field = 0;
}
''',
      [error(CrystallisCode.unsupportedClassModifier.code, 46, 14)],
    );
  }
}
