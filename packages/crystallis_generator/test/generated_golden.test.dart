import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

import 'package:crystallis_generator/crystallis_generator.dart';

const String outputPackage = 'a';

void main() {
  group('crystallis builder (golden-ish)', () {
    test('generates public class from source class', () async {
      final input = r'''
library example;

import 'package:crystallis/crystallis.dart';

@CrystallisData()
class User {
  @NotEmpty()
  String name;

  User({required this.name});
}
''';

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
      final input = r'''
library example;

import 'package:crystallis/crystallis.dart';

@CrystallisData()
class User {
  String name;
  User({required this.name});
}
''';

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
      final input = r'''
library example;

import 'package:crystallis/crystallis.dart';

@CrystallisData()
class Bad {
  final String name;
  $Bad({required this.name});
}
''';

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
      final input = r'''
library example;

import 'package:crystallis/crystallis.dart';

@CrystallisData(mutable: false)
class Bad {
  String name;
  const $Bad({required this.name});
}
''';

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
      final input = r'''
library example;

import 'package:crystallis/crystallis.dart';

@CrystallisData(mutable: false)
class User {
  @NotEmpty()
  final String name;

  const User({required this.name});
}
''';

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
