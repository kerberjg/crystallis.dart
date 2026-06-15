import 'package:crystallis/serialization.dart';
import 'package:test/test.dart';

void main() {
  group('default serialization', () {
    group('serialize', () {
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
          [2, 'y'],
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
            [2, 'y'],
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
            'k': [1, 'x', null],
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
              'k': [1, 'x', null],
            },
          }),
        );
      });

      test('unsupported type throws ArgumentError', () {
        expect(() => serializeValue(DateTime(2020, 1, 1)), throwsArgumentError);
      });
    });

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
        [2, 'y'],
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
          [2, 'y'],
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
          'k': [1, 'x', null],
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
            'k': [1, 'x', null],
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
      expect(deserializeValue<int?>(null), isNull);
      expect(deserializeValue<double?>(null), isNull);
      expect(deserializeValue<bool?>(null), isNull);
      expect(deserializeValue<String?>(null), isNull);
    });

    test('String -> int', () {
      expect(deserializeValue<int>('42'), equals(42));
    });

    test('String -> double', () {
      expect(deserializeValue<double>('3.14'), equals(3.14));
    });

    test('String -> String', () {
      expect(deserializeValue<String>('hello'), equals('hello'));
    });

    test('String -> bool', () {
      expect(deserializeValue<bool>('true'), isTrue);
      expect(deserializeValue<bool>('false'), isFalse);
    });

    test('type -> self', () {
      expect(deserializeValue<int>(42), equals(42));
      expect(deserializeValue<double>(3.14), equals(3.14));
      expect(deserializeValue<String>('hello'), equals('hello'));
      expect(deserializeValue<bool>(true), isTrue);
      expect(deserializeValue<bool>(false), isFalse);
    });

    test('type -> nullable self', () {
      expect(deserializeValue<int?>(''), isNull);
      expect(deserializeValue<double?>(''), isNull);
      expect(deserializeValue<String?>(''), equals('')); // ha!
      expect(deserializeValue<bool?>(''), isNull);
      expect(deserializeValue<bool?>(''), isNull);
    });

    test('List recursively deserializes elements', () {
      final input = [
        1,
        2.5,
        'x',
        true,
        null,
        [2, 'y'],
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
          [2, 'y'],
        ]),
      );
    });

    test('Map recursively deserializes keys and values', () {
      final input = <dynamic, dynamic>{
        'a': 1,
        2: 'b',
        true: null,
        'nested': <dynamic, dynamic>{
          'k': [1, 'x', null],
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
            'k': [1, 'x', null],
          },
        }),
      );
    });

    test('unsupported type throws ArgumentError', () {
      expect(() => deserializeValue<DateTime>(DateTime(2020, 1, 1)), throwsArgumentError);
    });
  });

  group('collection deserializers', () {
    test('deserializeMap<K, V> deserializes keys and values', () {
      final input = <String, dynamic>{
        'a': 1,
        'b': '2',
        'c': null,
        'd': true,
      };

      final output = deserializeMap(input);

      expect(
        output,
        equals(<String, dynamic>{
          'a': 1,
          'b': '2',
          'c': null,
          'd': true,
        }),
      );
    });

    test('deserializeMap<K, V> throws ArgumentError for non-string keys', () {
      final input = <dynamic, dynamic>{
        'a': 1,
        2: 'b',
        true: null,
      };

      expect(() => deserializeMap(input), throwsArgumentError);
    });

    test('deserializeMap<K, V> throws ArgumentError for unsupported value types', () {
      final input = <String, dynamic>{
        'a': DateTime(2020, 1, 1),
      };

      expect(() => deserializeMap(input), throwsArgumentError);
    });

    test('deserializeMap<K, V> deserializes non-string keys correctly', () {
      final input = <int, dynamic>{
        1: 'a',
        2: 'b',
        104: 'c',
      };

      final serialized = serializeMap(input);

      final Map<int, dynamic> output = deserializeMap(serialized);

      expect(
        output,
        equals(<int, dynamic>{
          1: 'a',
          2: 'b',
          104: 'c',
        }),
      );
    });
  });

  group('_fallbackDeserializeValue', () {
    test('should handle supported primitive types', () {
      expect(fallbackDeserializeValue<int>(42), equals(42));
      expect(fallbackDeserializeValue<double>(3.14), equals(3.14));
      expect(fallbackDeserializeValue<String>('hello'), equals('hello'));
      expect(fallbackDeserializeValue<bool>(true), isTrue);
      expect(fallbackDeserializeValue<bool>(false), isFalse);
      expect(fallbackDeserializeValue(null), isNull);
    });

    test('should support collections', () {
      expect(fallbackDeserializeValue<List>([1, 2, 3]), equals([1, 2, 3]));
      expect(fallbackDeserializeValue<Map>(<String, int>{'a': 1}), equals(<String, int>{'a': 1}));
    });

    test('should support nexted collections', () {
      final input = <dynamic, dynamic>{
        'a': [1, 2, 3],
        'b': <String, int>{'x': 10},
      };
      final output = fallbackDeserializeValue(input);
      expect(
        output,
        equals(<dynamic, dynamic>{
          'a': [1, 2, 3],
          'b': <String, int>{'x': 10},
        }),
      );
    });

    test('should throw ArgumentError for unsupported types', () {
      expect(() => fallbackDeserializeValue<DateTime>(DateTime(2020, 1, 1)), throwsArgumentError);
    });

    test('should return only string keys in Map', () {
      final input = <dynamic, dynamic>{
        'a': 1,
        2: 'b',
        true: null,
      };
      final output = fallbackDeserializeValue(input);
      expect(
        output,
        equals(<dynamic, dynamic>{
          'a': 1,
          '2': 'b',
          'true': null,
        }),
      );
    });
  });

  group('Serializer<T, U> helpers', () {
    test('serializeUntyped / deserializeUntyped forward correctly', () {
      const s = Serializable<int, String>(
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
