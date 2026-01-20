export 'validators/range.dart';
export 'validators/not_empty.dart';
export 'validators/email.dart';
export 'validators/chars.dart';
export 'validators/length.dart';
export 'validators/values.dart';
export 'validators/regex.dart';

class DataClass {
  /// Mutable by default
  final bool mutable;

  const DataClass({this.mutable = true});
}
