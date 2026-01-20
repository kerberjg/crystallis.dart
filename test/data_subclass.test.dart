import 'package:test/test.dart';
import 'package:crystallis/crystallis.dart';

class _ValidateHarness with DataSubclass {
  _ValidateHarness(this._x);

  final String _x;

  static final Map<String, FieldMetadata> _meta = Map.unmodifiable({
    'x': FieldMetadata(
      name: 'x',
      type: String,
      validators: const [NotEmpty(), LengthRange(min: 2, max: 4)],
    ),
    // Field with zero validators must still appear in validate()
    'y': FieldMetadata(
      name: 'y',
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
        return 123;
      default:
        throw ArgumentError.value(field, 'field');
    }
  }
}

void main() {
  test('validate() includes fields with zero validators', () {
    final h = _ValidateHarness('ok');

    final m = h.validate();
    expect(m.keys.toSet(), {'x', 'y'});

    expect(m['y'], isNotNull);
    expect(m['y']!, isEmpty);
  });

  test('validateField returns all failures for the field', () {
    final h = _ValidateHarness('');

    final errs = h.validateField('x');
    expect(errs.length, 2);
    expect(errs.map((e) => e.validator.runtimeType).toSet(),
        {NotEmpty, LengthRange});
  });
}
