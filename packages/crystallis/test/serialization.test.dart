import 'package:crystallis/runtime/serializer.dart';
import 'package:test/test.dart';

void main() {
  group('default serialization', () {
    test('null -> null', () {
      expect(serialize(null), isNull);
    });

    test('int -> int', () {
      expect(serialize(42), equals(42));
    });

    test('double -> double', () {
      expect(serialize(3.14), equals(3.14));
    });

    test('String -> String', () {
      expect(serialize('hello'), equals('hello'));
    });

    test('bool -> bool', () {
      expect(serialize(true), isTrue);
      expect(serialize(false), isFalse);
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
      final output = serialize(input);
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
        2: 'b',
        true: null,
        'nested': <dynamic, dynamic>{
          'k': [1, 'x', null]
        },
      };

      final output = serialize(input);

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
      expect(() => serialize(DateTime(2020, 1, 1)), throwsArgumentError);
    });
  });

  group('deserialize', () {
    test('null -> null', () {
      expect(deserialize(null), isNull);
    });

    test('int -> int', () {
      expect(deserialize(42), equals(42));
    });

    test('double -> double', () {
      expect(deserialize(3.14), equals(3.14));
    });

    test('String -> String', () {
      expect(deserialize('hello'), equals('hello'));
    });

    test('bool -> bool', () {
      expect(deserialize(true), isTrue);
      expect(deserialize(false), isFalse);
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
      final output = deserialize(input);
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

      final output = deserialize(input);

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
      expect(() => deserialize(DateTime(2020, 1, 1)), throwsArgumentError);
    });
  });

  group('Serializer<T, U> helpers', () {
    test('serializeUntyped / deserializeUntyped forward correctly', () {
      const s = Serializer<int, String>(
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
