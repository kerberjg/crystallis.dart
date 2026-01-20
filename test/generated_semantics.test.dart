import 'package:test/test.dart';
import 'package:crystallis/crystallis.dart';

class MutableUser with DataSubclass {
  MutableUser({required this.name});

  String name;

  static final Map<String, FieldMetadata> _meta = Map.unmodifiable({
    'name': FieldMetadata(
      name: 'name',
      type: String,
      validators: const [NotEmpty(), LengthRange(min: 2, max: 4)],
    ),
  });

  @override
  Map<String, FieldMetadata> get metadata => _meta;

  @override
  Object? get(String field) {
    switch (field) {
      case 'name':
        return name;
      default:
        throw ArgumentError.value(field, 'field');
    }
  }

  void set<T>(String field, T value) {
    final meta = metadata[field];
    if (meta == null) throw ArgumentError.value(field, 'field');

    if (value == null || value.runtimeType != meta.type) {
      throw ArgumentError.value(value, 'value');
    }

    final errors = <ValidationException>[];
    for (final v in meta.validators) {
      final err = v.validate(value);
      if (err != null) errors.add(err);
    }
    if (errors.isNotEmpty) throw errors;

    switch (field) {
      case 'name':
        name = value as String;
        return;
      default:
        throw ArgumentError.value(field, 'field');
    }
  }
}

class ImmutableUser with DataSubclass {
  const ImmutableUser({required this.name});

  final String name;

  static final Map<String, FieldMetadata> _meta = Map.unmodifiable({
    'name': FieldMetadata(
      name: 'name',
      type: String,
      validators: const [NotEmpty(), LengthRange(min: 2, max: 4)],
    ),
  });

  @override
  Map<String, FieldMetadata> get metadata => _meta;

  @override
  Object? get(String field) {
    switch (field) {
      case 'name':
        return name;
      default:
        throw ArgumentError.value(field, 'field');
    }
  }

  ImmutableUser set<T>(String field, T value) {
    final meta = metadata[field];
    if (meta == null) throw ArgumentError.value(field, 'field');

    if (value == null || value.runtimeType != meta.type) {
      throw ArgumentError.value(value, 'value');
    }

    final errors = <ValidationException>[];
    for (final v in meta.validators) {
      final err = v.validate(value);
      if (err != null) errors.add(err);
    }
    if (errors.isNotEmpty) throw errors;

    switch (field) {
      case 'name':
        return ImmutableUser(name: value as String);
      default:
        throw ArgumentError.value(field, 'field');
    }
  }
}

void main() {
  test('metadata is unmodifiable', () {
    expect(
        () => MutableUser._meta['x'] =
            FieldMetadata(name: 'x', type: int, validators: const []),
        throwsA(anything));
  });

  test('set enforces meta.type (runtimeType equality)', () {
    final u = MutableUser(name: 'ok');
    expect(() => u.set('name', 123), throwsA(isA<ArgumentError>()));
  });

  test(
      'set collects all validation errors and throws List<ValidationException>',
      () {
    final u = MutableUser(name: 'ok');

    try {
      u.set('name', ''); // fails NotEmpty and LengthRange(min:2)
      fail('Expected exception');
    } catch (e) {
      expect(e, isA<List<ValidationException>>());
      final errs = e as List<ValidationException>;
      expect(errs.length, 2);
      expect(errs.map((x) => x.validator.runtimeType).toSet(),
          {NotEmpty, LengthRange});
    }
  });

  test('mutable set mutates when valid', () {
    final u = MutableUser(name: 'ok');
    u.set('name', 'ab');
    expect(u.name, 'ab');
  });

  test('immutable set returns new instance when valid', () {
    const u = ImmutableUser(name: 'ok');
    final u2 = u.set('name', 'ab');
    expect(u.name, 'ok');
    expect(u2.name, 'ab');
  });
}
