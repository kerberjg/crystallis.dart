import 'package:crystallis/runtime/serializer.dart';
import 'package:test/test.dart';
import 'package:crystallis/crystallis.dart';

class _ValidateHarness with CrystallisData, MutableCrystallisData {
  _ValidateHarness(this._x, this._y);

  String _x;
  String _y;

  @override
  Crystallise get config => const Crystallise(
    mutable: false,
  );

  static final Map<String, FieldMetadata> _meta = Map.unmodifiable({
    'x': FieldMetadata(
      name: 'x',
      type: String,
      validators: const [NotEmpty(), LengthRange(min: 2, max: 4)],
    ),
    // Field with zero validators must still appear in validate()
    'y': FieldMetadata(
      name: 'y',
      type: String,
      validators: const [],
    ),
    'custom': FieldMetadata(
      name: 'custom',
      type: String,
      validators: const [],
      serializer: Serializable<String, String>(
        serialize: (value) => 'serialized',
        deserialize: (value) => 'deserialized',
      ),
    ),
  });

  @override
  Map<String, FieldMetadata> get metadata => _meta;

  @override
  Object? get(String field) {
    switch (field) {
      case 'x':
        return _x;
      case 'y':
        return _y;
      case 'custom':
        return 'value';
      default:
        throw ArgumentError.value(field, 'field');
    }
  }

  @override
  void set<T>(String field, T value) {
    switch (field) {
      case 'x':
        _x = value as String;
        return;
      case 'y':
        _y = value as String;
        return;
      default:
        throw ArgumentError.value(field, 'field');
    }
  }
}

// Has similar fields to [_ValidateHarness], plus a
class _ValidateHarness2 with CrystallisData, MutableCrystallisData {
  _ValidateHarness2(this._x, this._y, this._z);

  String _x;
  int _y;
  int _z;

  @override
  Crystallise get config => const Crystallise(
    mutable: true,
  );

  static final Map<String, FieldMetadata> _meta = Map.unmodifiable({
    'x': FieldMetadata(
      name: 'x',
      type: String,
      validators: const [NotEmpty(), LengthRange(min: 2, max: 4)],
      mutable: true,
    ),
    'y': FieldMetadata(
      name: 'y',
      type: int,
      validators: const [],
      mutable: true,
    ),
    'z': FieldMetadata(
      name: 'z',
      type: int,
      validators: const [],
      mutable: true,
    ),
  });

  @override
  Map<String, FieldMetadata> get metadata => _meta;

  @override
  Object? get(String field) {
    switch (field) {
      case 'x':
        return _x;
      case 'y':
        return _y;
      case 'z':
        return _z;
      default:
        throw ArgumentError.value(field, 'field');
    }
  }

  @override
  void set<T>(String field, T value) {
    assertSet(field, value);

    switch (field) {
      case 'x':
        _x = value as String;
        return;
      case 'y':
        _y = value as int;
        return;
      case 'z':
        _z = value as int;
        return;
      default:
        throw ArgumentError.value(field, 'field');
    }
  }
}

/// Immutable variant of [_ValidateHarness]
class _ValidateHarness3 with CrystallisData, ImmutableCrystallisData {
  const _ValidateHarness3(this._x, this._y);

  final String _x;
  final String _y;

  @override
  Crystallise get config => const Crystallise(
    mutable: false,
  );

  static final Map<String, FieldMetadata> _meta = Map.unmodifiable({
    'x': FieldMetadata(
      name: 'x',
      type: String,
      validators: const [NotEmpty(), LengthRange(min: 2, max: 4)],
    ),
    'y': FieldMetadata(
      name: 'y',
      type: String,
      validators: const [],
    ),
  });

  @override
  Map<String, FieldMetadata> get metadata => _meta;

  @override
  Object? get(String field) {
    switch (field) {
      case 'x':
        return _x;
      case 'y':
        return _y;
      default:
        throw ArgumentError.value(field, 'field');
    }
  }
}

// same as [_ValidateHarness2], but with nullable fields to test that null values are skipped in setFrom
class _ValidateHarness4 with CrystallisData, MutableCrystallisData {
  _ValidateHarness4(this._x, this._y, this._z);

  String? _x;
  int? _y;
  int? _z;

  @override
  Crystallise get config => const Crystallise(
    mutable: true,
  );

  static final Map<String, FieldMetadata> _meta = Map.unmodifiable({
    'x': FieldMetadata(
      name: 'x',
      type: String,
      validators: const [NotEmpty(), LengthRange(min: 2, max: 4)],
      mutable: true,
    ),
    'y': FieldMetadata(
      name: 'y',
      type: int,
      validators: const [],
      mutable: true,
    ),
    'z': FieldMetadata(
      name: 'z',
      type: int,
      validators: const [],
      mutable: true,
    ),
  });

  @override
  Map<String, FieldMetadata> get metadata => _meta;

  @override
  Object? get(String field) {
    switch (field) {
      case 'x':
        return _x;
      case 'y':
        return _y;
      case 'z':
        return _z;
      default:
        throw ArgumentError.value(field, 'field');
    }
  }

  @override
  void set<T>(String field, T value) {
    assertSet(field, value);

    switch (field) {
      case 'x':
        _x = value as String?;
        return;
      case 'y':
        _y = value as int?;
        return;
      case 'z':
        _z = value as int?;
        return;
      default:
        throw ArgumentError.value(field, 'field');
    }
  }
}

void main() {
  group('validation', () {
    test('validate() includes fields with zero validators', () {
      final h = _ValidateHarness('ok', 'also ok');

      final m = h.validate();
      expect(m.keys.toSet(), {'x', 'y', 'custom'});

      expect(m['y'], isNotNull);
      expect(m['y']!, isEmpty);
    });

    test('validateField returns all failures for the field', () {
      final h = _ValidateHarness('', '');

      final errs = h.validateField('x');
      expect(errs.length, 2);
      expect(
        errs.map((e) => e.validator.runtimeType).toSet(),
        {NotEmpty, LengthRange},
      );
    });

    test('toMap calls defaultSerializer by default', () {
      final h = _ValidateHarness('value', 'also value');

      final m = h.serialize();
      expect(m['x'], equals('value'));
      expect(m['y'], equals('also value'));
    });

    test('serialize uses custom serializer if provided', () {
      final h = _ValidateHarness('value', 'also value');

      final m = h.serialize();
      expect(m['custom'], equals('serialized'));
    });
  });

  group('set', () {
    test('enforces type from metadata', () {
      final h = _ValidateHarness2('ok', 123, 456);
      expect((() => h.set('x', 123)), throwsA(isA<TypeError>()));
      expect(() => h.set('y', 'not an int'), throwsA(isA<TypeError>()));
    });

    test('collects all validation errors and throws List<ValidationException>', () {
      final h = _ValidateHarness2('ok', 123, 456);

      try {
        h.set('x', ''); // fails NotEmpty and LengthRange(min:2)
        fail('Expected exception');
      } catch (e) {
        expect(e, isA<List<ValidationException>>());
        final errs = e as List<ValidationException>;
        expect(errs.length, 2);
        expect(errs.map((x) => x.validator.runtimeType).toSet(), {NotEmpty, LengthRange});
      }
    });

    test('mutable set mutates when valid', () {
      final h = _ValidateHarness2('ok', 123, 456);
      h.set('x', 'ab');
      expect(h.get('x'), 'ab');
    });

    test('immutable set throws when called', () {
      const h = _ValidateHarness3('ok', 'also ok');
      expect(() => h.set('x', 'ab'), throwsA(isA<StateError>()));
    });
  });

  group('setFrom', () {
    test('copies compatible fields and skips incompatible ones', () {
      final h1 = _ValidateHarness2('h1', 123, 456);
      final h2 = _ValidateHarness3('h2', 'also h2');

      h1.setFrom(h2);

      // Compatible field 'x' is copied
      expect(h1.get('x'), 'h2');

      // Incompatible field 'y' is unchanged
      expect(h1.get('y'), 123);

      // Incompatible field 'z' is unchanged
      expect(h1.get('z'), 456);
    });

    test('skips null values', () {
      final h1 = _ValidateHarness2('h1', 123, 456);
      final h2 = _ValidateHarness4(null, 321, null);

      h1.setFrom(h2);

      // Field 'x' is not updated because the value from h2 fails validation
      expect(h1.get('x'), 'h1');
    });

    test('should throw if calling on immutable class', () {
      final h1 = _ValidateHarness3('h1', 'also h1');
      final h2 = _ValidateHarness2('h2', 123, 456);

      expect(() => h1.setFrom(h2), throwsA(isA<StateError>()));
    });
  });
}
