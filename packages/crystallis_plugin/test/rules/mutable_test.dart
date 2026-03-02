import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:crystallis_plugin/src/rules/mutable.dart';
import 'package:essential_lints_annotations/essential_lints_annotations.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/crystallis_dependency.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MutableTest);
  });
}

@reflectiveTest
@SortingMembers({.method(#setUp), .methods}, alphabetizeSortedMembers: true, linesAroundSortedMembers: 1)
class MutableTest extends AnalysisRuleTest with CrystallisDependency {
  @override
  Future<void> setUp() async {
    rule = MutableRule();
    await addCrystallisDependency();
    super.setUp();
  }

  Future<void> test_immutable() async {
    await assertNoDiagnostics('''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: false)
class ImmutableClass {
  const ImmutableClass();
  final int finalField = 0;
}
''');
  }

  Future<void> test_immutable_constConstructor() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: false)
class ImmutableClass {
  ImmutableClass();
}
''',
      [lint(100, 14)],
    );
  }

  Future<void> test_immutable_constConstructor2() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: false)
class ImmutableClass {
  new();
}
''',
      [lint(100, 3)],
    );
  }

  Future<void> test_immutable_nonFinalPrimary() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: false)
// ignore: const_constructor_with_non_final_field
class const ImmutableClass(
  var int nonFinalField,
);
''',
      [lint(155, 3)],
    );
  }

  Future<void> test_immutable_nonFinalPrimary_nonFinalBody() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: false)
// ignore: const_constructor_with_non_final_field
class const ImmutableClass(
  var int nonFinalField,
) {
  int nonFinalField2 = nonFinalField;
}
''',
      [lint(155, 3), lint(184, 3)],
    );
  }

  Future<void> test_immutable_nonFinalType() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: false)
// ignore: const_constructor_with_non_final_field
class const ImmutableClass() {
  int nonFinalField = 0;
}
''',
      [lint(158, 3)],
    );
  }

  Future<void> test_immutable_nonFinalVar() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: false)
// ignore: const_constructor_with_non_final_field
class const ImmutableClass() {
  var nonFinalField = 0;
}
''',
      [lint(158, 3)],
    );
  }

  Future<void> test_immutable_primaryConstConstructor() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: false)
class ImmutableClass();
''',
      [lint(81, 14)],
    );
  }

  Future<void> test_mutable() async {
    await assertNoDiagnostics('''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: true)
class MutableClass(var int paramField) {
  int field = 0;
}
''');
  }

  Future<void> test_mutable_constConstructor() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: true)
class MutableClass {
  const MutableClass();
}
''',
      [lint(97, 5)],
    );
  }

  Future<void> test_mutable_constConstructor2() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: true)
class MutableClass {
  const new();
}
''',
      [lint(97, 5)],
    );
  }

  Future<void> test_mutable_finalPrimary() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: true)
class MutableClass(
  final int finalField,
);
''',
      [lint(96, 5)],
    );
  }

  Future<void> test_mutable_finalPrimary_nonFinalBody() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: true)
class const MutableClass(
  final int finalField,
) {
  final finalField2 = finalField;
}
''',
      [lint(102, 5), lint(130, 5)],
    );
  }

  Future<void> test_mutable_primaryConstConstructor() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: true)
class const MutableClass();
''',
      [lint(80, 5)],
    );
  }
}
