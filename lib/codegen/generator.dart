import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../annotations.dart';
import '../runtime/validator.dart';

Builder crystallisBuilder(BuilderOptions options) {
  return LibraryBuilder(
    CrystallisGenerator(), //
    generatedExtension: '.data.g.dart', //
    options: options, //
  );
}

class CrystallisGenerator extends GeneratorForAnnotation<DataClass> {
  static final _validatorChecker =
      TypeChecker.typeNamed(Validator, inPackage: 'crystallis');

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@DataClass can only be applied to classes.',
        element: element,
      );
    }

    const String definitionPrefix = '\$';
    final String className = element.name ?? "";
    if (!className.startsWith(definitionPrefix)) {
      throw InvalidGenerationSourceError(
        'DataClass source classes must start with "$definitionPrefix"',
        element: element,
      );
    }

    final mutable = annotation.peek('mutable')?.boolValue ?? true;
    final publicName = className.substring(1);

    final fields = element.fields
        .where((f) => !f.isStatic)
        .where((f) => f.getter != null)
        .toList();

    for (final f in fields) {
      if (mutable && f.isFinal) {
        throw InvalidGenerationSourceError(
          'Mutable DataClass fields must not be final: ${f.name}',
          element: f,
        );
      }
      if (!mutable && !f.isFinal) {
        throw InvalidGenerationSourceError(
          'Immutable DataClass fields must be final: ${f.name}',
          element: f,
        );
      }
    }

    final buffer = StringBuffer();

    // imports
    if (!mutable) buffer.writeln("import 'package:meta/meta.dart';");
    buffer.writeln("import 'package:crystallis/crystallis.dart';");
    buffer.writeln("import '${buildStep.inputId.uri}';");
    buffer.writeln();

    // class declaration
    if (!mutable) {
      buffer.writeln("@immutable");
    }
    buffer.writeln('class $publicName extends $className with DataSubclass {');

    // constructor
    if (!mutable && element.constructors.any((c) => c.isConst)) {
      buffer.write('  const ');
    } else {
      buffer.write('  ');
    }

    buffer.write('$publicName({');
    for (final f in fields) {
      buffer.write('required super.${f.name},');
    }
    buffer.writeln('});');
    buffer.writeln();

    const String metadataDoc =
        "/// Static immutable [FieldMetadata] for the fields of this data class.";

    // metadata
    buffer.write('  ');
    buffer.writeln(metadataDoc);
    buffer.writeln(
        '  static final Map<String, FieldMetadata> _metadata = Map.unmodifiable({');

    for (final f in fields) {
      final validators = _validatorsForField(f);

      buffer.writeln("    '${f.name}': FieldMetadata(");
      buffer.writeln("      name: '${f.name}',");
      buffer.writeln("      type: ${f.type.getDisplayString()},");
      buffer.writeln('      validators: $validators,');
      buffer.writeln('    ),');
    }

    buffer.writeln('  });');
    buffer.writeln();

    buffer.write('  ');
    buffer.writeln(metadataDoc);
    buffer.writeln(
        '  static Map<String, FieldMetadata> get metadataStatic => _metadata;');
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
    buffer
        .writeln('      default: throw ArgumentError.value(field, \'field\');');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();

    // set()
    if (mutable) {
      buffer.writeln('  void set<T>(String field, T value) {');
    } else {
      buffer.writeln('  $publicName set<T>(String field, T value) {');
    }

    buffer.writeln('    final meta = metadata[field];');
    buffer.writeln(
        '    if (meta == null) throw ArgumentError.value(field, \'field\');');
    buffer
        .writeln('    if (value == null || value.runtimeType != meta.type) {');
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
    buffer
        .writeln('      default: throw ArgumentError.value(field, \'field\');');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();

    // copyWith
    buffer.write('  $publicName copyWith({');
    for (final f in fields) {
      buffer.write('${_nullableType(f.type)} ${f.name},');
    }
    buffer.writeln('}) {');

    buffer.write('    return $publicName(');
    for (final f in fields) {
      buffer.write('${f.name}: ${f.name} ?? this.${f.name},');
    }
    buffer.writeln(');');
    buffer.writeln('  }');

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

    return out.isEmpty ? 'const []' : '[${out.join(',')}]';
  }

  String _castType(DartType type) => type.getDisplayString();

  /// Returns the type as a nullable type string.
  String _nullableType(DartType type) {
    final base = type.getDisplayString();
    if (type.nullabilitySuffix == NullabilitySuffix.none) {
      return '$base?';
    } else {
      return '$base';
    }
  }
}
