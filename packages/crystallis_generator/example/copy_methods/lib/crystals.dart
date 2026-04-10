// ignore_for_file: public_member_api_docs

import 'package:crystallis/crystallis.dart';

/// See the doc at the top of the file for instructions on how to generate the data class and run these tests.
@Crystallise(mutable: false)
class ShallowTest {
  const ShallowTest({
    required this.value,
    required this.nullableValue,
    required this.listValue,
  });

  final String value;
  final int? nullableValue;
  final List<String> listValue;
}

/// See the doc at the top of the file for instructions on how to generate the data class and run these tests.
@Crystallise(mutable: false, useDeepCopy: true)
class DeepTest {
  const DeepTest({
    required this.value,
    required this.nullableValue,
    required this.listValue,
  });

  final String value;
  final int? nullableValue;
  final List<String> listValue;
}
