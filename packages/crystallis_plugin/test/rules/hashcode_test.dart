import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:crystallis_plugin/src/rules/crystallis_code.dart';
import 'package:crystallis_plugin/src/rules/hashcode.dart';
import 'package:essential_lints_annotations/essential_lints_annotations.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/crystallis_dependency.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(HashCodeTest);
  });
}

@reflectiveTest
@SortingMembers({.method(#setUp), .methods}, alphabetizeSortedMembers: true, linesAroundSortedMembers: 1)
class HashCodeTest extends AnalysisRuleTest with CrystallisDependency {
  @override
  Future<void> setUp() async {
    rule = HashCodeRule();
    await addCrystallisDependency();
    super.setUp();
  }

  Future<void> test_defined() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise()
class MyClass {
  const MyClass();
  final int field = 0;

  @override
  int get hashCode => field.hashCode;
}
''',
      [error(CrystallisCode.hashCodeDefined.code, 142, 8)],
    );
  }

  Future<void> test_defined_disabled() async {
    await assertNoDiagnostics('''
import 'package:crystallis/crystallis.dart';

@Crystallise(hashCode: false)
class MyClass {
  const MyClass();
  final int field = 0;

  @override
  int get hashCode => field.hashCode;
}
''');
  }

  Future<void> test_defined_explicit() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(hashCode: true)
class MyClass {
  const MyClass();
  final int field = 0;

  @override
  int get hashCode => field.hashCode;
}
''',
      [error(CrystallisCode.hashCodeDefined.code, 156, 8)],
    );
  }

  Future<void> test_notAnnotated() async {
    await assertNoDiagnostics('''
class MyClass {
  const MyClass();
  final int field = 0;

  @override
  int get hashCode => field.hashCode;
}
''');
  }

  Future<void> test_undefined() async {
    await assertNoDiagnostics('''
import 'package:crystallis/crystallis.dart';

@Crystallise()
class MyClass {
  const MyClass();
  final int field = 0;
}
''');
  }
}
