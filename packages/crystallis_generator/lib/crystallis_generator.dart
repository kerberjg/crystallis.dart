import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:crystallis/api/serializer.dart';
import 'package:crystallis/api/validator.dart';
import 'package:crystallis/crystallis.dart';
import 'package:crystallis_generator/src/crystallis_enforcer.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

/// Comment flag used to indicate where imports should be added in the generated code.
const String importFlag = '// crystallis_generator(add_import):';

/// Entry point for the Crystallis code generator.
Builder crystallisBuilder(BuilderOptions options) {
  return LibraryBuilder(
    CrystallisGenerator(),
    generatedExtension: '.data.g.dart',
    options: options,
    formatOutput: (code, langVersion) {
      // check if running in a test
      final isTest = code.contains("package:cg_test/");

      // check if running in an example
      // (package name ends with '_example')
      final isExample = code
          .split('\n') //
          .where((line) => line.startsWith("import 'package:"))
          .map((line) => line.split('package:')[1].split('/')[0])
          .any((packageName) => packageName.endsWith('_example'));

      const String defaultFileHeader = '// GENERATED CODE - DO NOT MODIFY BY HAND';
      const String defaultDartFormatWidth = '// dart format width=80';
      const String testDartFormatWidth = '// dart format width=1000';
      const String disableAnalyzer = '// ignore_for_file: type=lint\n';

      code =
          '$defaultFileHeader\n'
          '${isTest ? testDartFormatWidth : defaultDartFormatWidth}\n'
          '${isTest || isExample ? '' : disableAnalyzer}\n'
          '${code.startsWith('$defaultFileHeader\n') ? code.substring(defaultFileHeader.length) : code}';

      // add imports after crystalllis import
      final Set<String> imports = code
          .split('\n')
          .where((line) => line.trim().startsWith(importFlag))
          .map((line) => 'import ${line.substring(importFlag.length + line.indexOf(importFlag)).trim()};')
          .toSet();

      // clean code of import flags
      code = code
          .split('\n') //
          .where((line) => !line.trim().startsWith(importFlag))
          .join('\n');

      final lines = code.split('\n');
      final int crystallisImportIndex = lines.indexWhere(
        (line) => line.startsWith("import 'package:crystallis/crystallis.dart';"),
      );

      if (crystallisImportIndex != -1) {
        final before = lines.sublist(0, crystallisImportIndex + 1);
        final after = lines.sublist(crystallisImportIndex + 1);
        code = [...before, ...imports, ...after].join('\n');
      }

      return DartFormatter(languageVersion: langVersion).format(code);
    },
  );
}

/// Code generator for classes annotated with [Crystallise].
class CrystallisGenerator extends GeneratorForAnnotation<Crystallise> {
  static final _validatorChecker = TypeChecker.typeNamed(Validator, inPackage: 'crystallis');

  // Keeps track of which libraries already have the imports written, to avoid duplicate imports when multiple classes are generated in the same library.
  final Set<Uri> _librariesWithImports = {};

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Crystallise can only be applied to classes.',
        element: element,
      );
    }

    if (CrystallisEnforcer.instance.classModifiersAreValid(element) case var error?) {
      throw InvalidGenerationSourceError(error, element: element);
    }

    const String crystallisSuffix = 'Data';
    final String className = element.name ?? "";
    final String publicName = className + crystallisSuffix;
    final bool mutable = annotation.peek('mutable')?.boolValue ?? true;
    final bool enableToString = annotation.peek('enableToString')?.boolValue ?? true;
    final bool enableEquals = annotation.peek('enableEquals')?.boolValue ?? true;
    final bool enableHashCode = annotation.peek('enableHashCode')?.boolValue ?? true;
    final bool useDeepEquality = annotation.peek('useDeepEquality')?.boolValue ?? true;
    final bool enableCopyWith = annotation.peek('enableCopyWith')?.boolValue ?? true;
    final bool useDeepCopy = annotation.peek('useDeepCopy')?.boolValue ?? false;
    const String importSerializer = '\'package:crystallis/serialization.dart\'';
    final bool enableDeserialize = annotation.peek('enableDeserialize')?.boolValue ?? true;

    final fields = element.fields.where((f) => !f.isStatic).where((f) => f.getter != null).toList();

    // Validate field (im)mutability
    for (final f in fields) {
      if (!mutable && !f.isFinal) {
        throw InvalidGenerationSourceError(
          'Immutable CrystallisData fields must be final: ${f.name}',
          element: f,
        );
      }
    }

    // Validate `toString` generation
    if (CrystallisEnforcer.instance.toStringIsValid(element) case var error? when enableToString) {
      throw InvalidGenerationSourceError(error, element: element);
    }

    // Validate `equals` generation
    if (CrystallisEnforcer.instance.equalIsValid(element) case var error? when enableEquals) {
      throw InvalidGenerationSourceError(error, element: element);
    }

    // Validate `hashCode` generation
    if (CrystallisEnforcer.instance.hashCodeIsValid(element) case var error? when enableHashCode) {
      throw InvalidGenerationSourceError(error, element: element);
    }

    final buffer = StringBuffer();

    // imports
    // (write only if they haven't been written to this file before)
    if (!_librariesWithImports.contains(buildStep.inputId.uri)) {
      _librariesWithImports.add(buildStep.inputId.uri);
      buffer.writeln("import 'package:crystallis/crystallis.dart';");
      buffer.writeln("import '${buildStep.inputId.uri.asPackageOrBaseName}';");
      buffer.writeln();
    }

    final classDocs = '/// [CrystallisData] class for [$className].';
    buffer.writeln(classDocs);
    // class declaration
    if (!mutable) {
      buffer.writeln("@immutable");
    }
    buffer.writeln(
      'class $publicName extends $className with CrystallisData' +
          ', ${mutable ? "MutableCrystallisData" : "ImmutableCrystallisData"}' +
          ', ${enableCopyWith ? "CopyableCrystallisData<$publicName>" : ""} ' +
          ' {',
    );

    // config
    buffer.writeln('  @override');
    buffer.writeln('  Crystallise get config => const Crystallise(');
    buffer.writeln(
      annotation
          .revive()
          .namedArguments
          .map(
            (k, v) => MapEntry(
              k,
              v.toSymbolValue() ??
                  v.toBoolValue() ??
                  v.toIntValue() ??
                  v.toDoubleValue() ??
                  v.toStringValue() ??
                  v.toListValue() ??
                  v.toMapValue() ??
                  v.toSetValue() ??
                  'null',
            ),
          )
          .entries
          .map((e) => '    ${e.key}: ${e.value},')
          .join('\n'),
    );
    buffer.writeln('  );');
    buffer.writeln();

    // constructor
    buffer.writeln('  $classDocs');
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
      buffer.writeln(
        '  /// Deserializer constructor for creating an instance of [$publicName] from a `Map<String, dynamic>`.',
      );
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
      buffer.writeln("      mutable: ${!f.isFinal},");
      buffer.writeln('      validators: $validators,');

      // Add custom serializer if the field has an annotation that implements
      // the [SerializingAnnotation] interface.
      final serializerChecker = TypeChecker.typeNamed(Serializer, inPackage: 'crystallis');

      final serializers = f.metadata.annotations.where(
        (a) =>
            a.computeConstantValue()?.type != null &&
            serializerChecker.isAssignableFromType(a.computeConstantValue()!.type!),
      );

      if (serializers.isNotEmpty) {
        buffer.writeln('  $importFlag $importSerializer');

        /*
         *  Custom serializer handling
         */
        if (serializers.length > 1) {
          /// TODO(kerberjg): test this
          throw InvalidGenerationSourceError(
            'Field ${f.name} has multiple serializers. Only one serializer annotation is allowed per field.',
            element: f,
          );
        }

        final s = serializers.first;

        buffer.writeln(
          '      serializer: ${s.toSource().substring(1)},',
        );
      } else {
        /*
         *  Default serializer handling
         */
        if (f.type.isDartCoreMap) {
          buffer.writeln('  $importFlag $importSerializer');
          buffer.writeln(
            '      serializer: MapSerializer<${_typeArguments(f.type).join(', ')}>(),',
          );
        }
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
      buffer.writeln('    assertSet(field, value);');
      buffer.writeln();

      buffer.writeln('    switch (field) {');
      for (final f in fields) {
        // skip final fields since they can't be set
        if (f.isFinal) {
          buffer.writeln("      // case '${f.name}':");
          buffer.writeln("      //   ${f.name} is final");
          buffer.writeln('      //   return;');
          continue;
        }

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
      buffer.writeln('  @override');
      buffer.write('  $publicName Function({');
      for (final f in fields) {
        buffer.write('${f.type.getDisplayString()} ${f.name},');
      }
      buffer.writeln('}) get copyWith => _innerCopyWith;');
      buffer.writeln();

      buffer.writeln('  @pragma("vm:always-consider-inlining")');
      buffer.write('  $publicName _innerCopyWith({');
      var objectQuestionType = element.library.typeProvider.objectQuestionType;
      var objectType = element.library.typeProvider.objectType;
      for (final f in fields) {
        buffer.write('${f.type.isNullable ? objectQuestionType : objectType} ${f.name} = CrystallisData.nullValue,');
      }
      buffer.writeln('}) => $publicName(');
      for (final f in fields) {
        var prefix = ' ' * 6;
        buffer.write('$prefix${f.name}: ${f.name} == CrystallisData.nullValue');
        if (useDeepCopy && (f.type.isDartCoreList || f.type.isDartCoreSet || f.type.isDartCoreMap)) {
          final bool curly = !f.type.isDartCoreList;
          String open = curly ? '{' : '[';
          String close = curly ? '}' : ']';

          buffer.writeln();
          buffer.write('$prefix  ? (');
          if (f.type.isNullable) {
            buffer.write('this.${f.name} == null ? null : ');
          }
          buffer.writeln('$open...${f.type.isNullable ? '?' : ''}this.${f.name}$close)');
          buffer.write('$prefix  : (');
          if (f.type.isNullable) buffer.write('${f.name} == null ? null : ');
          buffer.writeln('$open...${f.name} as ${_nonNullableType(f.type)}$close),');
        } else {
          buffer.writeln('? this.${f.name} : ${f.name} as ${f.type.getDisplayString()},');
        }
      }
      buffer.writeln(');');
      buffer.writeln();

      // copyFrom (like setFrom, but returns a new instance instead of modifying this)
      buffer.writeln('  @override');
      buffer.write('  $publicName copyFrom(CrystallisData other) {');
      buffer.write('    return _innerCopyWith(');
      for (final f in fields) {
        buffer.write(
          '${f.name}: other.tryCopy<${_castType(f.type)}>(\'${f.name}\')${f.type.isNullable ? '' : '!'},',
        );
      }
      buffer.writeln(');');
      buffer.writeln('  }');
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
  // ignore: unused_element
  String _nullableType(DartType type) {
    final base = type.getDisplayString();
    if (type.nullabilitySuffix == NullabilitySuffix.none) {
      return '$base?';
    } else {
      return base;
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

extension on Uri {
  String get asPackageOrBaseName => scheme == 'package' ? this.toString() : pathSegments.last;
}

extension on DartType {
  bool get isNullable => nullabilitySuffix == NullabilitySuffix.question;
}
