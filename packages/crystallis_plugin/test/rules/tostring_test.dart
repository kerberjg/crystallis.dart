import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:crystallis_plugin/src/rules/crystallis_code.dart';
import 'package:crystallis_plugin/src/rules/tostring.dart';
import 'package:essential_lints_annotations/essential_lints_annotations.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/crystallis_dependency.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ToStringTest);
  });
}

@reflectiveTest
@SortingMembers({.method(#setUp), .methods}, alphabetizeSortedMembers: true, linesAroundSortedMembers: 1)
class ToStringTest extends AnalysisRuleTest with CrystallisDependency {
  @override
  Future<void> setUp() async {
    rule = ToStringRule();
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
  String toString() => 'MyClass(field: \$field)';
}
''',
      [error(CrystallisCode.toStringDefined.code, 141, 8)],
    );
  }

  Future<void> test_defined_disabled() async {
    await assertNoDiagnostics('''
import 'package:crystallis/crystallis.dart';

@Crystallise(toString: false)
class MyClass {
  const MyClass();
  final int field = 0;

  @override
  String toString() => 'MyClass(field: \$field)';
}
''');
  }

  Future<void> test_defined_explicit() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(toString: true)
class MyClass {
  const MyClass();
  final int field = 0;

  @override
  String toString() => 'MyClass(field: \$field)';
}
''',
      [error(CrystallisCode.toStringDefined.code, 155, 8)],
    );
  }

  Future<void> test_notAnnotated() async {
    await assertNoDiagnostics('''
class MyClass {
  const MyClass();
  final int field = 0;

  @override
  String toString() => 'MyClass(field: \$field)';
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
