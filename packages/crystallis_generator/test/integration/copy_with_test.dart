// This test needs a real build step to test the copyWith generation, so we generate the file with:
//
// dart run packages/crystallis_generator/tool/generate_all.dart
//
// After that, we can run these tests.

import 'package:crystallis/annotations.dart';
import 'package:test/test.dart';

import 'generated/copy_with.dart';

Future<void> main() async {
  group('copyWith', () {
    group('shallow', () {
      test('exact values, different instance', () {
        final data = const ShallowTestData(value: 'test', nullableValue: 42, listValue: ['a']);
        final copy = data.copyWith();
        expect(copy, equals(data));
        expect(identical(copy, data), isFalse);
      });
      test('keep original values', () {
        final list = ['a'];
        final data = ShallowTestData(value: 'test', nullableValue: 42, listValue: list);
        final copy = data.copyWith();
        expect(copy.value, equals('test'));
        expect(copy.nullableValue, equals(42));
        expect(identical(list, copy.listValue), isTrue);
      });
      test('change some values', () {
        final list = ['a'];
        final data = ShallowTestData(value: 'test', nullableValue: 42, listValue: list);
        final copy = data.copyWith(value: 'new value', nullableValue: 3);
        expect(copy.value, equals('new value'));
        expect(copy.nullableValue, equals(3));
      });
      test('can set to null', () {
        final data = const ShallowTestData(value: 'test', nullableValue: 42, listValue: ['a']);
        final copy = data.copyWith(nullableValue: null);
        expect(copy.value, equals('test'));
        expect(copy.nullableValue, isNull);
        expect(identical(const ['a'], copy.listValue), isTrue);
      });
      test('list is the same instance', () {
        final list = ['a'];
        final data = ShallowTestData(value: 'test', nullableValue: 42, listValue: list);
        final copy = data.copyWith();
        expect(identical(copy.listValue, list), isTrue);
      });
      test('copyFrom', () {
        final data = const ShallowTestData(value: 'test', nullableValue: 42, listValue: ['a']);
        final other = const ShallowTestData(value: 'other', nullableValue: null, listValue: ['b']);
        final copy = data.copyFrom(other);
        expect(copy.value, equals('other'));
        expect(copy.nullableValue, isNull);
        expect(identical(const ['b'], copy.listValue), isTrue);
      });
    });
    group('deep', () {
      test('different list even when unspecified', () {
        final list = ['a'];
        final data = DeepTestData(value: 'test', nullableValue: 42, listValue: list);
        final copy = data.copyWith();
        expect(identical(copy.listValue, list), isFalse);
        expect(copy.listValue, equals(list));
      });
      test('different list when changed for the same instance', () {
        final list = ['a'];
        final data = DeepTestData(value: 'test', nullableValue: 42, listValue: list);
        final copy = data.copyWith(listValue: list);
        expect(identical(copy.listValue, list), isFalse);
        expect(copy.listValue, equals(list));
      });
    });
  });
}


/// See the doc at the top of the file for instructions on how to generate the data class and run these tests.
@Crystallise(mutable: false)
class ShallowTest {
  const ShallowTest({required this.value, required this.nullableValue, required this.listValue});

  final String value;
  final int? nullableValue;
  final List<String> listValue;
}

/// See the doc at the top of the file for instructions on how to generate the data class and run these tests.
@Crystallise(mutable: false, useDeepCopy: true)
class DeepTest {
  const DeepTest({required this.value, required this.nullableValue, required this.listValue});

  final String value;
  final int? nullableValue;
  final List<String> listValue;
}
