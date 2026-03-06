import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:crystallis_plugin/src/rules/crystallis_code.dart';
import 'package:crystallis_plugin/src/rules/mutability.dart';
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
    rule = MutabilityRule();
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

  Future<void> test_immutable_nonConstConstructor() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: false)
class ImmutableClass {
  ImmutableClass();
}
''',
      [error(CrystallisCode.nonConstConstructor.code, 100, 14)],
    );
  }

  Future<void> test_immutable_nonConstConstructor2() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: false)
class ImmutableClass {
  new();
}
''',
      [error(CrystallisCode.nonConstConstructor.code, 100, 3)],
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
      [error(CrystallisCode.mutableField.code, 155, 3)],
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
      [error(CrystallisCode.mutableField.code, 155, 3), error(CrystallisCode.mutableField.code, 184, 3)],
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
      [error(CrystallisCode.mutableField.code, 158, 3)],
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
      [error(CrystallisCode.mutableField.code, 158, 3)],
    );
  }

  Future<void> test_immutable_primaryConstConstructor() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: false)
class ImmutableClass();
''',
      [error(CrystallisCode.nonConstConstructor.code, 81, 14)],
    );
  }

  Future<void> test_immutable_requiredNamedParameters_nonConst() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: false)
class ImmutableClass {
  ImmutableClass({required this.finalField});
  final int finalField;
}
''',
      [error(CrystallisCode.nonConstConstructor.code, 100, 14)],
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
      [error(CrystallisCode.constConstructor.code, 97, 5)],
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
      [error(CrystallisCode.constConstructor.code, 97, 5)],
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
      [error(CrystallisCode.immutableField.code, 96, 5)],
    );
  }

  Future<void> test_mutable_finalPrimary_nonFinalBody() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: true)
class MutableClass(
  final int finalField,
) {
  final finalField2 = finalField;
}
''',
      [error(CrystallisCode.immutableField.code, 96, 5), error(CrystallisCode.immutableField.code, 124, 5)],
    );
  }

  Future<void> test_mutable_primaryConstConstructor() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: true)
class const MutableClass();
''',
      [error(CrystallisCode.constConstructor.code, 80, 5)],
    );
  }

  Future<void> test_mutable_requiredNamedParameters_const() async {
    await assertDiagnostics(
      '''
import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: true)
class ImmutableClass {
  // ignore: const_constructor_with_non_final_field
  const ImmutableClass({required this.field});
  int field;
}
''',
      [error(CrystallisCode.constConstructor.code, 151, 5)],
    );
  }
}
