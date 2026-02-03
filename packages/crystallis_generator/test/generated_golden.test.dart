import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

import 'package:crystallis_generator/crystallis_generator.dart';

const String outputPackage = 'a';

const Map<String, String> _testClasses = {
  //
  'mutable': r'''
library example;
import 'package:crystallis/crystallis.dart';

@CrystallisData(mutable: true)
class User {
  String name;

  User({required this.name});
}''',
  //
  'mutableWithImmutableField': r'''
library example;
import 'package:crystallis/crystallis.dart';

@CrystallisData(mutable: true)
class User {
  final String name;
  User({required this.name});
}''',
  //
  'mutableWithValidation': r'''
library example;
import 'package:crystallis/crystallis.dart';

@CrystallisData(mutable: true)
class User {
  @NotEmpty()
  String name;

  User({required this.name});
}''',
  //
  'immutable': r'''
library example;
import 'package:crystallis/crystallis.dart';

@CrystallisData(mutable: false)
class User {
  final String name;
  const User({required this.name});
}''',
  //
  'immutableWithMutableField': r'''
library example;
import 'package:crystallis/crystallis.dart';

@CrystallisData(mutable: false)
class User {
  String name;
  User({required this.name});
}''',
  //
  'immutableWithValidation': r'''
library example;
import 'package:crystallis/crystallis.dart';
@CrystallisData(mutable: false)
class User {
  @NotEmpty()
  final String name;

  const User({required this.name});
}''',
  //
  'immutableWithToString': r'''
library example;
import 'package:crystallis/crystallis.dart';
@CrystallisData(mutable: false, toString: true, equals: false, hashCode: false)
class User {
  final String name;
  final int age;

  const User({
    required this.name,
    required this.age,
  });
}''',
  //
  'immutableWithShallowEquals': r'''
library example;
import 'package:crystallis/crystallis.dart';
@CrystallisData(mutable: false, toString: false, equals: true, hashCode: false, useDeepEquality: false)
class Dot {
  final int color;
  final List<int> position;
  const Dot({
    required this.color,
    required this.position,
  });
}''',
  //
  'immutableWithShallowHashCode': r'''
library example;
import 'package:crystallis/crystallis.dart';
@CrystallisData(mutable: false, toString: false, equals: false, hashCode: true, useDeepEquality: false)
class Dot {
  final int color;
  final List<int> position;
  const Dot({
    required this.color,
    required this.position,
  });
}''',
  //
  'immutableWithDeepHashCode': r'''
library example;
import 'package:crystallis/crystallis.dart';
@CrystallisData(mutable: false, toString: false, equals: false, hashCode: true, useDeepEquality: true)
class Dot {
  final int color;
  final List<int> position;
  const Dot({
    required this.color,
    required this.position,
  });
}''',
  //
  'immutableWithDeepEquals': r'''
library example;
import 'package:crystallis/crystallis.dart';
@CrystallisData(mutable: false, toString: false, equals: true, hashCode: false, useDeepEquality: true)
class Dot {
  final int color;
  final List<int> position;
  const Dot({
    required this.color,
    required this.position,
  });
}''',
  //
  'immutableAlreadyHasToString': r'''
library example;
import 'package:crystallis/crystallis.dart';
@CrystallisData(mutable: false, toString: true, equals: false, hashCode: false)
class User {
  final String name;
  const User({required this.name});

  @override
  String toString() {
    return 'Custom toString: \$name';
  }
}''',
  //
  'immutableAlreadyHasEquals': r'''
library example;
import 'package:crystallis/crystallis.dart';
@CrystallisData(mutable: false, toString: false, equals: true, hashCode: false)
class User {
  final String name;
  const User({required this.name});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! User) return false;
    return other.name == name;
  }
}''',
  //
  'immutableAlreadyHasHashCode': r'''
library example;
import 'package:crystallis/crystallis.dart';
@CrystallisData(mutable: false, toString: false, equals: false, hashCode: true)
class User {
  final String name;
  const User({required this.name});

  @override
  int get hashCode => name.hashCode;
}''',
};

void main() {
  group('crystallis builder (golden-ish)', () {
    test('generates public class from source class', () async {
      final input = _testClasses['mutableWithValidation']!;

      final outputs = await _runBuilder(
        inputDartPath: '$outputPackage|lib/user.dart',
        inputDart: input,
      );

      final outPath = '$outputPackage|lib/user.data.g.dart';
      final generated = outputs[outPath];
      expect(generated, isNotNull, reason: 'Expected output at $outPath');

      // Key expectations
      // TODO: use analyzer for those
      expect(generated,
          contains('class UserData extends User with CrystallisMixin'));
      expect(generated,
          contains('Map<String, FieldMetadata> get metadata => _metadata'));
      expect(generated, contains("case 'name':"));
      expect(generated, contains('final errors = <ValidationException>[];'));
      expect(generated, contains('if (errors.isNotEmpty) throw errors;'));
      expect(generated, contains("name = value as String;"));
    });

    test('adds suffix to source class name', () async {
      final input = _testClasses['mutable']!;

      final outputs = await _runBuilder(
        inputDartPath: '$outputPackage|lib/user.dart',
        inputDart: input,
      );

      final outPath = '$outputPackage|lib/user.data.g.dart';
      final generated = outputs[outPath];
      expect(generated, isNotNull, reason: 'Expected output at $outPath');

      expect(generated,
          contains('class UserData extends User with CrystallisMixin'));
    });

    test('mutable default: rejects final fields', () async {
      final input = _testClasses['mutableWithImmutableField']!;

      try {
        await _runBuilder(
          inputDartPath: '$outputPackage|lib/bad_mutable.dart',
          inputDart: input,
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('immutable: rejects non-final fields', () async {
      final input = _testClasses['immutableWithMutableField']!;

      try {
        await _runBuilder(
          inputDartPath: '$outputPackage|lib/bad_immutable.dart',
          inputDart: input,
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('immutable: set<T> returns new instance (signature check)', () async {
      final input = _testClasses['immutableWithValidation']!;

      final outputs = await _runBuilder(
        inputDartPath: '$outputPackage|lib/user_immutable.dart',
        inputDart: input,
      );

      final generated =
          outputs['$outputPackage|lib/user_immutable.data.g.dart']!;
      expect(generated, contains('UserData set<T>(String field, T value)'));
      expect(generated, contains('return UserData('));
    });
  });

  test("generates a valid toString method", () async {
    final input = _testClasses['immutableWithToString']!;

    final outputs = await _runBuilder(
      inputDartPath: '$outputPackage|lib/user.dart',
      inputDart: input,
    );

    final generated = outputs['$outputPackage|lib/user.data.g.dart']!;
    expect(generated, contains("return 'UserData(name: \$name, age: \$age)';"));
  });

  test("generates a valid (shallow) equals method", () async {
    final input = _testClasses['immutableWithShallowEquals']!;

    final outputs = await _runBuilder(
      inputDartPath: '$outputPackage|lib/dot.dart',
      inputDart: input,
    );

    final generated = outputs['$outputPackage|lib/dot.data.g.dart']!;
    expect(generated, contains('if (other is! DotData) return false;'));
    expect(generated, contains('other.position == position'));
  });

  test("generates a valid (deep) equals method", () async {
    final input = _testClasses['immutableWithDeepEquals']!;

    final outputs = await _runBuilder(
      inputDartPath: '$outputPackage|lib/dot.dart',
      inputDart: input,
    );

    final generated = outputs['$outputPackage|lib/dot.data.g.dart']!;
    expect(generated, contains('if (other is! DotData) return false;'));
    expect(
        generated,
        contains(
            'const DeepCollectionEquality().equals(other.position, position)'));
  });

  test("generates a valid (shallow) hashCode method", () async {
    final input = _testClasses['immutableWithShallowHashCode']!;

    final outputs = await _runBuilder(
      inputDartPath: '$outputPackage|lib/dot.dart',
      inputDart: input,
    );

    final generated = outputs['$outputPackage|lib/dot.data.g.dart']!;
    expect(generated, contains('int get hashCode {'));
    expect(generated, contains('Object.hashAll([color, position]);'));
  });

  test("generates a valid (deep) hashCode method", () async {
    final input = _testClasses['immutableWithDeepHashCode']!;

    final outputs = await _runBuilder(
      inputDartPath: '$outputPackage|lib/dot.dart',
      inputDart: input,
    );

    final generated = outputs['$outputPackage|lib/dot.data.g.dart']!;
    expect(generated, contains('int get hashCode {'));
    expect(
        generated, contains('const DeepCollectionEquality().hash(position)'));
  });
}

/// Runs the crystallis builder in-memory and returns all output assets.
Future<Map<String, String>> _runBuilder({
  required String inputDartPath,
  required String inputDart,
}) async {
  final builder = crystallisBuilder(const BuilderOptions({}, isRoot: true));

  final rw = TestReaderWriter(rootPackage: outputPackage);
  await rw.testing.loadIsolateSources();

  final result = await testBuilder(
    builder,
    {
      inputDartPath: inputDart,
    },
    outputs: null,
    readerWriter: rw,
    flattenOutput: true,
  );

  // // print all assets
  // for (final asset in rw.testing.assetsWritten) {
  //   print('Generated asset: ${asset}');
  //   print('  path: ${asset.path}');
  //   print('  package: ${asset.package}');
  //   print('  uri: ${asset.uri}');
  // }

  // // Collect all generated outputs.
  // for (final asset in result.outputs) {
  //   print('Output asset id: ${asset}');
  //   print('  path: ${asset.path}');
  //   print('  package: ${asset.package}');
  //   print('  uri: ${asset.uri}');
  // }

  /// Map of output asset paths to their contents.
  Map<String, String> outputs = {};

  for (final AssetId asset in result.outputs) {
    // print("reading generated asset: ${asset}");
    // print("  can read ${asset}: ${await rw.canRead(asset)}");
    // print("  exists ${asset}: ${await rw.testing.exists(asset)}");

    final content = rw.testing.readString(asset);
    outputs['${asset.package}|${asset.path}'] = content;
  }

  return outputs;
}
