import 'package:crystallis_plugin/src/rules/class_modifier.dart';
import 'package:essential_lints_annotations/essential_lints_annotations.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/mutlti_crystallis_rule_test.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ClassModifierTest);
  });
}

@reflectiveTest
@SortingMembers({.method(#setUp), .methods}, alphabetizeSortedMembers: true, linesAroundSortedMembers: 1)
class ClassModifierTest extends MutltiCrystallisRuleTest<ClassModifierCode> {
  @override
  get rule => ClassModifierRule();

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
      [code(.final_, 46, 14)],
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
      [code(.private, 46, 14)],
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
      [code(.sealed_, 46, 14)],
    );
  }
}
