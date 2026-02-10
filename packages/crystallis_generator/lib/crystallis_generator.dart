// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:crystallis/crystallis.dart';
import 'package:source_gen/source_gen.dart';

Builder crystallisBuilder(BuilderOptions options) {
  return LibraryBuilder(
    CrystallisGenerator(), //
    generatedExtension: '.data.g.dart', //
    options: options, //
  );
}

class CrystallisGenerator extends GeneratorForAnnotation<CrystallisData> {
  static final _validatorChecker = TypeChecker.typeNamed(Validator, inPackage: 'crystallis');

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@CrystallisData can only be applied to classes.',
        element: element,
      );
    }

    const String crystallisSuffix = 'Data';
    final String className = element.name ?? "";
    final String publicName = className + crystallisSuffix;
    final bool mutable = annotation.peek('mutable')?.boolValue ?? true;
    final bool enableToString = annotation.peek('toString')?.boolValue ?? true;
    final bool enableEquals = annotation.peek('equals')?.boolValue ?? true;
    final bool enableHashCode = annotation.peek('hashCode')?.boolValue ?? true;
    final bool useDeepEquality = annotation.peek('useDeepEquality')?.boolValue ?? true;
    final bool enableCopyWith = annotation.peek('copyWith')?.boolValue ?? true;
    final bool useDeepCopy = annotation.peek('useDeepCopy')?.boolValue ?? false;
    final bool enableDeserialize = annotation.peek('deserialize')?.boolValue ?? true;

    final fields = element.fields.where((f) => !f.isStatic).where((f) => f.getter != null).toList();

    // Validate field (im)mutability
    for (final f in fields) {
      if (mutable && f.isFinal) {
        throw InvalidGenerationSourceError(
          'Mutable CrystallisData fields must not be final: ${f.name}',
          element: f,
        );
      }
      if (!mutable && !f.isFinal) {
        throw InvalidGenerationSourceError(
          'Immutable CrystallisData fields must be final: ${f.name}',
          element: f,
        );
      }
    }

    // Validate `toString` generation
    if (enableToString && element.getMethod('toString') != null) {
      throw InvalidGenerationSourceError(
        'Cannot generate toString() method: already defined in $className.',
        element: element,
      );
    }

    // Validate `equals` generation
    if (enableEquals && element.getMethod('==') != null) {
      throw InvalidGenerationSourceError(
        'Cannot generate equals (==) method: already defined in $className.',
        element: element,
      );
    }

    // Validate `hashCode` generation
    if (enableHashCode && element.getMethod('hashCode') != null) {
      throw InvalidGenerationSourceError(
        'Cannot generate hashCode method: already defined in $className.',
        element: element,
      );
    }

    final buffer = StringBuffer();

    // imports
    buffer.writeln("import 'package:crystallis/crystallis.dart';");
    buffer.writeln("import 'package:crystallis/runtime/serializer.dart';");
    buffer.writeln("import '${buildStep.inputId.uri}';");
    buffer.writeln();

    if (enableCopyWith) {
      buffer.writeln('enum _Sentinel { i }');
      buffer.writeln();
    }

    // class declaration
    if (!mutable) {
      buffer.writeln("@immutable");
    }
    buffer.writeln('class $publicName extends $className with CrystallisMixin {');

    // constructor
    if (!mutable && element.constructors.any((c) => c.isConst)) {
      buffer.write('  const ');
    } else {
      buffer.write('  ');
    }

    buffer.write('$publicName({');
    for (final f in fields) {
      if (_isNullable(f.type)) {
        buffer.write('super.${f.name},');
      } else {
        buffer.write('required super.${f.name},');
      }
    }
    buffer.writeln('});');
    buffer.writeln();

    // deserializer constructor
    if (enableDeserialize) {
      buffer.writeln('  factory $publicName.deserialize(Map<String, dynamic> data) =>');
      buffer.writeln('      $publicName(');
      for (final f in fields) {
        final type = f.type;

        buffer.write(
          "        ${f.name}: _metadata['${f.name}']!.serializer.deserialize(data['${f.name}'])",
        );

        final needsCast = type is ParameterizedType && type.typeArguments.isNotEmpty;
        final castTypes = _typeArguments(type);

        if (needsCast) {
          buffer.write('.cast<${castTypes.join(', ')}>()');
        }

        buffer.writeln(',');
      }
      buffer.writeln('      );');
      buffer.writeln();
    }

    const String metadataDoc = "/// Static immutable [FieldMetadata] for the fields of this data class.";

    // metadata
    buffer.write('  ');
    buffer.writeln(metadataDoc);
    buffer.writeln('  static const Map<String, FieldMetadata> _metadata = {');

    for (final f in fields) {
      final validators = _validatorsForField(f);

      buffer.writeln("    '${f.name}': FieldMetadata(");
      buffer.writeln("      name: '${f.name}',");
      buffer.writeln("      type: ${_nonNullableType(f.type)},");
      buffer.writeln("      nullable: ${_isNullable(f.type)},");
      buffer.writeln('      validators: $validators,');

      if (f.type.isDartCoreMap) {
        buffer.writeln(
          '      serializer: MapSerializer<${_typeArguments(f.type).join(', ')}>(),',
        );
      }

      buffer.writeln('    ),');
    }

    buffer.writeln('  };');
    buffer.writeln();

    buffer.write('  ');
    buffer.writeln(metadataDoc);
    buffer.writeln('  static Map<String, FieldMetadata> get metadataStatic => _metadata;');
    buffer.writeln();

    buffer.write('  ');
    buffer.writeln(metadataDoc);
    buffer.writeln('  @override');
    buffer.writeln('  Map<String, FieldMetadata> get metadata => _metadata;');
    buffer.writeln();

    // get()
    buffer.writeln('  @override');
    buffer.writeln('  Object? get(String field) {');
    buffer.writeln('    switch (field) {');
    for (final f in fields) {
      buffer.writeln("      case '${f.name}': return ${f.name};");
    }
    buffer.writeln('      default: throw ArgumentError.value(field, \'field\');');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();

    // set()
    buffer.writeln('  @override');
    buffer.writeln('  void set<T>(String field, T value) {');
    if (mutable) {
      buffer.writeln('    final meta = metadata[field];');
      buffer.writeln('    if (meta == null) throw ArgumentError.value(field, \'field\');');
      buffer.writeln('    if (value == null || value.runtimeType != meta.type) {');
      buffer.writeln('      throw ArgumentError.value(value, \'value\');');
      buffer.writeln('    }');

      buffer.writeln('    final errors = <ValidationException>[];');
      buffer.writeln('    for (final v in meta.validators) {');
      buffer.writeln('      final err = v.validate(value);');
      buffer.writeln('      if (err != null) errors.add(err);');
      buffer.writeln('    }');
      buffer.writeln('    if (errors.isNotEmpty) throw errors;');

      buffer.writeln('    switch (field) {');
      for (final f in fields) {
        buffer.writeln("      case '${f.name}':");
        if (mutable) {
          buffer.writeln('        ${f.name} = value as ${_castType(f.type)};');
          buffer.writeln('        return;');
        } else {
          buffer.write('        return $publicName(');
          for (final other in fields) {
            if (other == f) {
              buffer.write('${other.name}: value as ${_castType(other.type)},');
            } else {
              buffer.write('${other.name}: ${other.name},');
            }
          }
          buffer.writeln(');');
        }
      }
      buffer.writeln('      default: throw ArgumentError.value(field, \'field\');');
      buffer.writeln('    }');
    } else {
      // immutable: throw error
      buffer.writeln("    throw StateError('Cannot set field on immutable type $publicName.');");
    }
    buffer.writeln('  }');
    buffer.writeln();

    // copyWith
    if (enableCopyWith) {
      buffer.write('  $publicName Function({');
      for (final f in fields) {
        buffer.write('${f.type.getDisplayString()} ${f.name},');
      }
      buffer.write('}) get copyWith => ({');
      var objectQuestionType = element.library.typeProvider.objectQuestionType;
      var objectType = element.library.typeProvider.objectType;
      for (final f in fields) {
        buffer.write('${f.type.isNullable ? objectQuestionType : objectType} ${f.name} = _Sentinel.i,');
      }
      buffer.writeln('}) => $publicName(');
      for (final f in fields) {
        var prefix = ' ' * 6;
        buffer.write('$prefix${f.name}: ${f.name} == _Sentinel.i');
        if (useDeepCopy && (f.type.isDartCoreList || f.type.isDartCoreSet || f.type.isDartCoreMap)) {
          final bool curly = !f.type.isDartCoreList;
          String open = curly ? '{' : '[';
          String close = curly ? '}' : ']';

          buffer.writeln();
          buffer.write('$prefix  ? (');
          if (f.type.isNullable) buffer.write('this.${f.name} == null ? null : ');
          buffer.writeln('$open...${f.type.isNullable ? '?' : ''}this.${f.name} $close)');
          buffer.write('$prefix  : (');
          if (f.type.isNullable) buffer.write('${f.name} == null ? null : ');
          buffer.writeln('$open...${f.name} as ${_nonNullableType(f.type)}$close),');
        } else {
          buffer.writeln('? this.${f.name} : ${f.name} as ${f.type.getDisplayString()},');
        }
      }
      buffer.writeln(');');
      buffer.writeln();
    }

    // toString
    if (enableToString) {
      buffer.writeln('  @override');
      buffer.writeln('  String toString() {');
      buffer.write("    return '$publicName(");

      for (var i = 0; i < fields.length; i++) {
        final f = fields[i];
        if (i > 0) buffer.write(', ');
        buffer.write('${f.name}: \$${f.name}');
      }

      buffer.writeln(")';");
      buffer.writeln('  }');
      buffer.writeln();
    }

    // equals
    if (enableEquals) {
      buffer.writeln('  @override');
      buffer.writeln('  bool operator ==(Object other) {');
      buffer.writeln('    if (identical(this, other)) return true;');
      buffer.writeln('    if (other is! $publicName) return false;');
      buffer.write('    return ');
      for (var i = 0; i < fields.length; i++) {
        final f = fields[i];
        if (i > 0) buffer.write(' && ');

        // use DeepCollectionEquality for lists, maps, sets
        if (useDeepEquality && (f.type.isDartCoreList || f.type.isDartCoreSet || f.type.isDartCoreMap)) {
          buffer.write('const DeepCollectionEquality().equals(other.${f.name}, ${f.name})');
        } else {
          buffer.write('other.${f.name} == ${f.name}');
        }
      }

      buffer.writeln(';');
      buffer.writeln('  }');
      buffer.writeln();
    }

    // hashCode
    if (enableHashCode) {
      buffer.writeln('  @override');
      buffer.writeln('  int get hashCode {');
      buffer.write('    return Object.hashAll([');
      for (final f in fields) {
        // use DeepCollectionEquality for lists, maps, sets
        if (useDeepEquality && (f.type.isDartCoreList || f.type.isDartCoreSet || f.type.isDartCoreMap)) {
          buffer.write('const DeepCollectionEquality().hash(${f.name}), ');
        } else {
          buffer.write('${f.name}, ');
        }
      }
      buffer.writeln(']);');
      buffer.writeln('  }');
      buffer.writeln();
    }

    buffer.writeln('}');
    buffer.writeln();

    return buffer.toString();
  }

  String _validatorsForField(FieldElement field) {
    final out = <String>[];

    for (final m in field.metadata.annotations) {
      final obj = m.computeConstantValue();
      if (obj == null) continue;

      final type = obj.type;
      if (type == null) continue;

      if (_validatorChecker.isAssignableFromType(type)) {
        out.add(m.toSource().substring(1)); // remove leading '@'
      }
    }

    return '[${out.join(',')}]';
  }

  String _castType(DartType type) => type.getDisplayString();

  List<String> _typeArguments(DartType type) {
    if (type is ParameterizedType) {
      return type.typeArguments
          .map((t) => t.getDisplayString()) //
          .toList();
    } else {
      return [];
    }
  }

  /// Returns the type as a nullable type string.
  String _nullableType(DartType type) {
    final base = type.getDisplayString();
    if (type.nullabilitySuffix == NullabilitySuffix.none) {
      return '$base?';
    } else {
      return '$base';
    }
  }

  /// Returns the type as a non-nullable type string.
  String _nonNullableType(DartType type) {
    final base = type.getDisplayString();
    if (type.nullabilitySuffix == NullabilitySuffix.question) {
      return base.substring(0, base.length - 1);
    } else {
      return base;
    }
  }

  /// Whether the type is nullable.
  bool _isNullable(DartType type) {
    return type.nullabilitySuffix == NullabilitySuffix.question;
  }
}

extension on DartType {
  bool get isNullable => nullabilitySuffix == NullabilitySuffix.question;
}
