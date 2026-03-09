// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// CrystallisGenerator
// **************************************************************************

import 'package:crystallis/crystallis.dart';
import 'package:crystallis/runtime/serializer.dart';
import '../copy_with_test.dart';

@immutable
class ShallowTestData extends ShallowTest
    with CrystallisData, ImmutableCrystallisData {
  @override
  Crystallise get config => const Crystallise(mutable: false);

  const ShallowTestData({
    required super.value,
    super.nullableValue,
    required super.listValue,
  });

  factory ShallowTestData.deserialize(Map<String, dynamic> data) =>
      ShallowTestData(
        value: _metadata['value']!.serializer.deserialize(data['value']),
        nullableValue: _metadata['nullableValue']!.serializer.deserialize(
          data['nullableValue'],
        ),
        listValue: _metadata['listValue']!.serializer
            .deserialize(data['listValue'])
            .cast<String>(),
      );

  /// Static immutable [FieldMetadata] for the fields of this data class.
  static const Map<String, FieldMetadata> _metadata = {
    'value': FieldMetadata(
      name: 'value',
      type: String,
      nullable: false,
      mutable: false,
      validators: [],
    ),
    'nullableValue': FieldMetadata(
      name: 'nullableValue',
      type: int,
      nullable: true,
      mutable: false,
      validators: [],
    ),
    'listValue': FieldMetadata(
      name: 'listValue',
      type: List<String>,
      nullable: false,
      mutable: false,
      validators: [],
    ),
  };

  /// Static immutable [FieldMetadata] for the fields of this data class.
  static Map<String, FieldMetadata> get metadataStatic => _metadata;

  /// Static immutable [FieldMetadata] for the fields of this data class.
  @override
  Map<String, FieldMetadata> get metadata => _metadata;

  @override
  Object? get(String field) {
    switch (field) {
      case 'value':
        return value;
      case 'nullableValue':
        return nullableValue;
      case 'listValue':
        return listValue;
      default:
        throw ArgumentError.value(field, 'field');
    }
  }

  @override
  void set<T>(String field, T value) {
    throw StateError('Cannot set field on immutable type ShallowTestData.');
  }

  ShallowTestData Function({
    String value,
    int? nullableValue,
    List<String> listValue,
  })
  get copyWith => _innerCopyWith;

  @pragma("vm:always-consider-inlining")
  ShallowTestData _innerCopyWith({
    Object value = CrystallisData.nullValue,
    Object? nullableValue = CrystallisData.nullValue,
    Object listValue = CrystallisData.nullValue,
  }) => ShallowTestData(
    value: value == CrystallisData.nullValue ? this.value : value as String,
    nullableValue: nullableValue == CrystallisData.nullValue
        ? this.nullableValue
        : nullableValue as int?,
    listValue: listValue == CrystallisData.nullValue
        ? this.listValue
        : listValue as List<String>,
  );

  ShallowTestData copyFrom(CrystallisData other) {
    return _innerCopyWith(
      value: other.tryCopy<String>('value')!,
      nullableValue: other.tryCopy<int?>('nullableValue'),
      listValue: other.tryCopy<List<String>>('listValue')!,
    );
  }

  @override
  String toString() {
    return 'ShallowTestData(value: $value, nullableValue: $nullableValue, listValue: $listValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShallowTestData) return false;
    return other.value == value &&
        other.nullableValue == nullableValue &&
        other.listValue == listValue;
  }

  @override
  int get hashCode {
    return Object.hashAll([value, nullableValue, listValue]);
  }
}

@immutable
class DeepTestData extends DeepTest
    with CrystallisData, ImmutableCrystallisData {
  @override
  Crystallise get config =>
      const Crystallise(mutable: false, useDeepCopy: true);

  const DeepTestData({
    required super.value,
    super.nullableValue,
    required super.listValue,
  });

  factory DeepTestData.deserialize(Map<String, dynamic> data) => DeepTestData(
    value: _metadata['value']!.serializer.deserialize(data['value']),
    nullableValue: _metadata['nullableValue']!.serializer.deserialize(
      data['nullableValue'],
    ),
    listValue: _metadata['listValue']!.serializer
        .deserialize(data['listValue'])
        .cast<String>(),
  );

  /// Static immutable [FieldMetadata] for the fields of this data class.
  static const Map<String, FieldMetadata> _metadata = {
    'value': FieldMetadata(
      name: 'value',
      type: String,
      nullable: false,
      mutable: false,
      validators: [],
    ),
    'nullableValue': FieldMetadata(
      name: 'nullableValue',
      type: int,
      nullable: true,
      mutable: false,
      validators: [],
    ),
    'listValue': FieldMetadata(
      name: 'listValue',
      type: List<String>,
      nullable: false,
      mutable: false,
      validators: [],
    ),
  };

  /// Static immutable [FieldMetadata] for the fields of this data class.
  static Map<String, FieldMetadata> get metadataStatic => _metadata;

  /// Static immutable [FieldMetadata] for the fields of this data class.
  @override
  Map<String, FieldMetadata> get metadata => _metadata;

  @override
  Object? get(String field) {
    switch (field) {
      case 'value':
        return value;
      case 'nullableValue':
        return nullableValue;
      case 'listValue':
        return listValue;
      default:
        throw ArgumentError.value(field, 'field');
    }
  }

  @override
  void set<T>(String field, T value) {
    throw StateError('Cannot set field on immutable type DeepTestData.');
  }

  DeepTestData Function({
    String value,
    int? nullableValue,
    List<String> listValue,
  })
  get copyWith => _innerCopyWith;

  @pragma("vm:always-consider-inlining")
  DeepTestData _innerCopyWith({
    Object value = CrystallisData.nullValue,
    Object? nullableValue = CrystallisData.nullValue,
    Object listValue = CrystallisData.nullValue,
  }) => DeepTestData(
    value: value == CrystallisData.nullValue ? this.value : value as String,
    nullableValue: nullableValue == CrystallisData.nullValue
        ? this.nullableValue
        : nullableValue as int?,
    listValue: listValue == CrystallisData.nullValue
        ? ([...this.listValue])
        : ([...listValue as List<String>]),
  );

  DeepTestData copyFrom(CrystallisData other) {
    return _innerCopyWith(
      value: other.tryCopy<String>('value')!,
      nullableValue: other.tryCopy<int?>('nullableValue'),
      listValue: other.tryCopy<List<String>>('listValue')!,
    );
  }

  @override
  String toString() {
    return 'DeepTestData(value: $value, nullableValue: $nullableValue, listValue: $listValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeepTestData) return false;
    return other.value == value &&
        other.nullableValue == nullableValue &&
        other.listValue == listValue;
  }

  @override
  int get hashCode {
    return Object.hashAll([value, nullableValue, listValue]);
  }
}
