import 'package:test/test.dart';
import 'package:crystallis/crystallis.dart';

void main() {
  group('Range', () {
    test('validates inclusive min/max', () {
      const v = Range(min: 1, max: 3, inclusive: true);

      expect(v.validate(1), isNull);
      expect(v.validate(2), isNull);
      expect(v.validate(3), isNull);

      expect(v.validate(0), isA<ValidationException>());
      expect(v.validate(4), isA<ValidationException>());
      expect(v.validate('x'), isA<ValidationException>());
      expect(v.validate(null), isA<ValidationException>());
    });

    test('validates exclusive min/max', () {
      const v = Range(min: 1, max: 3, inclusive: false);

      expect(v.validate(2), isNull);

      expect(v.validate(1), isA<ValidationException>());
      expect(v.validate(3), isA<ValidationException>());
    });
  });

  group('NotEmpty', () {
    test('works for String / Iterable / Map', () {
      const v = NotEmpty();

      expect(v.validate('a'), isNull);
      expect(v.validate(<int>[1]), isNull);
      expect(v.validate(<String, int>{'a': 1}), isNull);

      expect(v.validate(''), isA<ValidationException>());
      expect(v.validate(<int>[]), isA<ValidationException>());
      expect(v.validate(<String, int>{}), isA<ValidationException>());
      expect(v.validate(null), isA<ValidationException>());
    });
  });

  group('Email', () {
    test('accepts naive emails', () {
      const v = Email();

      expect(v.validate('a@b.com'), isNull);
      expect(v.validate('a+b@b.co'), isNull);

      expect(v.validate(''), isA<ValidationException>());
      expect(v.validate('not-an-email'), isA<ValidationException>());
      expect(v.validate('a@b'), isA<ValidationException>());
      expect(v.validate(null), isA<ValidationException>());
      expect(v.validate(123), isA<ValidationException>());
    });
  });

  group('AllowedChars + aliases', () {
    test('AllowedChars enforces whole-string match', () {
      const v = AllowedChars('abc');

      expect(v.validate(''), isNull);
      expect(v.validate('aabbcc'), isNull);

      expect(v.validate('abcz'), isA<ValidationException>());
      expect(v.validate('A'), isA<ValidationException>());
      expect(v.validate(null), isA<ValidationException>());
    });

    test('aliases', () {
      const upper = Uppercase();
      const lower = Lowercase();
      const nums = OnlyNumbers();
      const alphaNum = Alphanumeric();

      expect(upper.validate('ABC'), isNull);
      expect(upper.validate('AbC'), isA<ValidationException>());

      expect(lower.validate('abc'), isNull);
      expect(lower.validate('abC'), isA<ValidationException>());

      expect(nums.validate('0123'), isNull);
      expect(nums.validate('01a'), isA<ValidationException>());

      expect(alphaNum.validate('aZ09'), isNull);
      expect(alphaNum.validate('aZ09_'), isA<ValidationException>());
    });
  });

  group('Length / LengthRange', () {
    test('Length', () {
      const v = Length(3);

      expect(v.validate('abc'), isNull);
      expect(v.validate('ab'), isA<ValidationException>());
      expect(v.validate(123), isA<ValidationException>());
      expect(v.validate(null), isA<ValidationException>());
    });

    test('LengthRange inclusive/exclusive', () {
      const inc = LengthRange(min: 2, max: 4, inclusive: true);
      const exc = LengthRange(min: 2, max: 4, inclusive: false);

      expect(inc.validate('ab'), isNull);
      expect(inc.validate('abcd'), isNull);
      expect(inc.validate('a'), isA<ValidationException>());
      expect(inc.validate('abcde'), isA<ValidationException>());

      expect(exc.validate('ab'), isA<ValidationException>()); // == min
      expect(exc.validate('abc'), isNull);
      expect(exc.validate('abcd'), isA<ValidationException>()); // == max
    });
  });

  group('Values', () {
    test('uses List.contains equality', () {
      const v = AllowedValues({'admin', 'user', 1});

      expect(v.validate('admin'), isNull);
      expect(v.validate(1), isNull);

      expect(v.validate('guest'), isA<ValidationException>());
      expect(v.validate(null), isA<ValidationException>());
    });
  });
}
