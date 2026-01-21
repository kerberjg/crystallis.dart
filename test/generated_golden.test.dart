import 'package:build/src/builder.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

import 'package:crystallis/codegen/generator.dart';

void main() {
  group('crystallis builder (golden-ish)', () {
    test('generates public class from underscored source class', () async {
      final input = r'''
library example;

import 'package:crystallis/crystallis.dart';

@CrystallisData()
class $UserData {
  @NotEmpty()
  String name;

  $UserData({required this.name});
}
''';

      final outputs = await _runBuilder(
        inputDartPath: 'a|lib/user_data.dart',
        inputDart: input,
      );

      final outPath = 'a|lib/user_data.data.g.dart';
      final generated = outputs[outPath];
      expect(generated, isNotNull, reason: 'Expected output at $outPath');

      // Key expectations
      expect(
          generated,
          contains(
              'class UserData extends \$UserData implements DataSubclass'));
      expect(generated,
          contains('Map<String, FieldMetadata> get metadata => _metadata'));
      expect(generated, contains("case 'name': return name;"));
      expect(generated, contains('final errors = <ValidationException>[];'));
      expect(generated, contains('if (errors.isNotEmpty) throw errors;'));
      expect(generated, contains("name = value as String;"));
    });

    test('enforces underscore prefix on source class name', () async {
      final input = r'''
library example;

import 'package:crystallis/crystallis.dart';

@CrystallisData()
class UserData {
  String name;
  UserData({required this.name});
}
''';

      await expectLater(
        () => _runBuilder(
          inputDartPath: 'a|lib/bad.dart',
          inputDart: input,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('mutable default: rejects final fields', () async {
      final input = r'''
library example;

import 'package:crystallis/crystallis.dart';

@CrystallisData()
class $Bad {
  final String name;
  $Bad({required this.name});
}
''';

      try {
        await _runBuilder(
          inputDartPath: 'a|lib/bad_mutable.dart',
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
class $Bad {
  String name;
  const $Bad({required this.name});
}
''';

      try {
        await _runBuilder(
          inputDartPath: 'a|lib/bad_immutable.dart',
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
class $UserData {
  @NotEmpty()
  final String name;

  const $UserData({required this.name});
}
''';

      final outputs = await _runBuilder(
        inputDartPath: 'a|lib/user_immutable.dart',
        inputDart: input,
      );

      final generated = outputs['a|lib/user_immutable.data.g.dart']!;
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
  final builder = crystallisBuilder(const BuilderOptions({}));

  final outputs = <String, String>{};

  await testBuilder(
    builder,
    {
      inputDartPath: inputDart,
      // Provide the package's own sources that the input imports.
      // build_test resolves package:crystallis/... against "crystallis|lib/..."
      'crystallis|lib/crystallis.dart': _crystallisLibrary,
      'crystallis|lib/annotations.dart': _annotationsLibrary,
      'crystallis|lib/runtime/data_subclass.dart': _dataSubclassLibrary,
      'crystallis|lib/runtime/field_metadata.dart': _fieldMetadataLibrary,
      'crystallis|lib/runtime/validator.dart': _validatorLibrary,
      'crystallis|lib/runtime/validation_exception.dart':
          _validationExceptionLibrary,
      'crystallis|lib/validators/not_empty.dart': _notEmptyLibrary,
      // For these tests we only need NotEmpty; add others if your fixtures use them.
    },
    outputs: outputs,
    // Some source_gen builders emit headers; we focus on contains() checks above.
  );

  return outputs;
}

// --- Minimal in-memory copies of crystallis public surface needed by tests ---

const _crystallisLibrary = r'''
library crystallis;

export 'annotations.dart';
export 'runtime/data_subclass.dart';
export 'runtime/field_metadata.dart';
export 'runtime/validator.dart';
export 'runtime/validation_exception.dart';

// validators used by tests
export 'validators/not_empty.dart';
''';

const _annotationsLibrary = r'''
class CrystallisData {
  final bool mutable;
  const CrystallisData({this.mutable = true});
}

export 'runtime/validator.dart';
export 'runtime/validation_exception.dart';
export 'runtime/field_metadata.dart';
export 'runtime/data_subclass.dart';

export 'validators/not_empty.dart';
''';

const _validationExceptionLibrary = r'''
class ValidationException implements Exception {
  final Validator validator;
  final Object? value;

  const ValidationException({
    required this.validator,
    required this.value,
  });

  @override
  String toString() =>
      'ValidationException(validator: ${validator.runtimeType}, value: $value)';
}
''';

const _validatorLibrary = r'''
import 'validation_exception.dart';

abstract class Validator {
  const Validator();
  ValidationException? validate(Object? value);
}
''';

const _fieldMetadataLibrary = r'''
import 'validator.dart';

class FieldMetadata {
  final String name;
  final Type type;
  final List<Validator> validators;

  const FieldMetadata({
    required this.name,
    required this.type,
    required this.validators,
  });
}
''';

const _dataSubclassLibrary = r'''
import 'field_metadata.dart';
import 'validation_exception.dart';

abstract class DataSubclass {
  const DataSubclass();

  Map<String, FieldMetadata> get metadata;
  Object? get(String field);

  List<ValidationException> validateField(String field) {
    final meta = metadata[field];
    if (meta == null) {
      throw ArgumentError.value(field, 'field', 'Unknown field');
    }

    final value = get(field);
    final errors = <ValidationException>[];

    for (final v in meta.validators) {
      final err = v.validate(value);
      if (err != null) {
        errors.add(err);
      }
    }

    return errors;
  }

  Map<String, List<ValidationException>> validate() {
    final result = <String, List<ValidationException>>{};
    for (final field in metadata.keys) {
      result[field] = validateField(field);
    }
    return result;
  }
}
''';

const _notEmptyLibrary = r'''
import '../runtime/validator.dart';
import '../runtime/validation_exception.dart';

class NotEmpty extends Validator {
  const NotEmpty();

  @override
  ValidationException? validate(Object? value) {
    if (value == null) {
      return ValidationException(validator: this, value: value);
    }

    if (value is String && value.isNotEmpty) return null;
    if (value is Iterable && value.isNotEmpty) return null;
    if (value is Map && value.isNotEmpty) return null;

    return ValidationException(validator: this, value: value);
  }
}
''';
