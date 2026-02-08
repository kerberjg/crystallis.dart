import 'package:crystallis/runtime/serializer.dart';
import 'package:test/test.dart';

void main() {
  group('default serialization', () {
    test('null -> null', () {
      expect(serializeValue(null), isNull);
    });

    test('int -> int', () {
      expect(serializeValue(42), equals(42));
    });

    test('double -> double', () {
      expect(serializeValue(3.14), equals(3.14));
    });

    test('String -> String', () {
      expect(serializeValue('hello'), equals('hello'));
    });

    test('bool -> bool', () {
      expect(serializeValue(true), isTrue);
      expect(serializeValue(false), isFalse);
    });

    test('List recursively serializes elements', () {
      final input = [
        1,
        2.5,
        'x',
        true,
        null,
        [2, 'y']
      ];
      final output = serializeValue(input);
      expect(
        output,
        equals([
          1,
          2.5,
          'x',
          true,
          null,
          [2, 'y']
        ]),
      );
    });

    test('Map recursively serializes keys and values', () {
      final input = <dynamic, dynamic>{
        'a': 1,
        'b': '2',
        'c': null,
        'd': true,
        'nested': <dynamic, dynamic>{
          'k': [1, 'x', null]
        },
      };

      final output = serializeValue(input);

      expect(
        output,
        equals(<dynamic, dynamic>{
          'a': 1,
          'b': '2',
          'c': null,
          'd': true,
          'nested': <dynamic, dynamic>{
            'k': [1, 'x', null]
          },
        }),
      );
    });

    test('unsupported type throws ArgumentError', () {
      expect(() => serializeValue(DateTime(2020, 1, 1)), throwsArgumentError);
    });
  });

  group('deserialize', () {
    test('null -> null', () {
      expect(deserializeValue(null), isNull);
    });

    test('int -> int', () {
      expect(deserializeValue<int>(42), equals(42));
    });

    test('double -> double', () {
      expect(deserializeValue<double>(3.14), equals(3.14));
    });

    test('String -> String', () {
      expect(deserializeValue<String>('hello'), equals('hello'));
    });

    test('bool -> bool', () {
      expect(deserializeValue<bool>(true), isTrue);
      expect(deserializeValue<bool>(false), isFalse);
    });

    test('List recursively deserializes elements', () {
      final input = [
        1,
        2.5,
        'x',
        true,
        null,
        [2, 'y']
      ];
      final output = deserializeValue<List>(input);
      expect(
        output,
        equals([
          1,
          2.5,
          'x',
          true,
          null,
          [2, 'y']
        ]),
      );
    });

    test('Map recursively deserializes keys and values', () {
      final input = <dynamic, dynamic>{
        'a': 1,
        2: 'b',
        true: null,
        'nested': <dynamic, dynamic>{
          'k': [1, 'x', null]
        },
      };

      final output = deserializeValue(input);

      expect(
        output,
        equals(<dynamic, dynamic>{
          'a': 1,
          2: 'b',
          true: null,
          'nested': <dynamic, dynamic>{
            'k': [1, 'x', null]
          },
        }),
      );
    });

    test('unsupported type throws ArgumentError', () {
      expect(() => deserializeValue<DateTime>(DateTime(2020, 1, 1)), throwsArgumentError);
    });
  });

  group('Serializer<T, U> helpers', () {
    test('serializeUntyped / deserializeUntyped forward correctly', () {
      const s = CustomSerializer<int, String>(
        serialize: _intToString,
        deserialize: _stringToInt,
      );

      expect(s.serializeUntyped(12), equals('12'));
      expect(s.deserializeUntyped('34'), equals(34));
    });
  });
}

String _intToString(int v) => v.toString();
int _stringToInt(String v) => int.parse(v);
