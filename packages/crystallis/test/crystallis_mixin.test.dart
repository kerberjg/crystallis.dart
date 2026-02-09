import 'package:crystallis/runtime/serializer.dart';
import 'package:test/test.dart';
import 'package:crystallis/crystallis.dart';

class _ValidateHarness with CrystallisData {
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
      serializer: CustomSerializer<String, String>(
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
class _ValidateHarness2 with CrystallisData {
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
    ),
    'y': FieldMetadata(
      name: 'y',
      type: int,
      validators: const [],
    ),
    'z': FieldMetadata(
      name: 'z',
      type: int,
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
      case 'z':
        return _z;
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
class _ValidateHarness3 with CrystallisData {
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

  @override
  void set<T>(String field, T value) {
    throw UnsupportedError('This class is immutable');
  }
}

void main() {
  test('validate() includes fields with zero validators', () {
    final h = _ValidateHarness('ok');

    final m = h.validate();
    expect(m.keys.toSet(), {'x', 'y', 'custom'});

    expect(m['y'], isNotNull);
    expect(m['y']!, isEmpty);
  });

  test('validateField returns all failures for the field', () {
    final h = _ValidateHarness('');

    final errs = h.validateField('x');
    expect(errs.length, 2);
    expect(
      errs.map((e) => e.validator.runtimeType).toSet(),
      {NotEmpty, LengthRange},
    );
  });

  test('toMap calls defaultSerializer by default', () {
    final h = _ValidateHarness('value');

    final m = h.serialize();
    expect(m['x'], equals('value'));
    expect(m['y'], equals(123));
  });

  test('serialize uses custom serializer if provided', () {
    final h = _ValidateHarness('value');

    final m = h.serialize();
    expect(m['custom'], equals('serialized'));
  });
}
