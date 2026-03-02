import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:crystallis_plugin/src/rules/crystallis_code.dart';
import 'package:crystallis_plugin/src/rules/crystallis_rule.dart';
import 'package:crystallis_plugin/src/utils/annotation.dart';

/// {@template mutable_rule}
/// This rule checks for mutable fields in classes annotated with @Crystallis(mutable: false). It ensures that all
/// fields in such classes are final.
/// {@endtemplate}
class MutableRule extends MutltiCrystallisRule {
  /// {@macro mutable_rule}
  MutableRule() : super(name: baseName, description: baseDescription);

  /// The base name for the rule, used in diagnostics.
  static const baseName = 'crystallis_mutable';

  /// A human-readable description of the rule that is being violated.
  static const baseDescription =
      'This rule checks for mutable fields in classes annotated with @Crystallis to make sure they align with '
      "whatever 'mutable' value they were defined.";

  @override
  final List<CrystallisLintCode> diagnosticCodes = [
    CrystallisCode.mutableField.code,
    CrystallisCode.immutableField.code,
    CrystallisCode.constConstructor.code,
    CrystallisCode.nonConstConstructor.code,
  ];

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    var visitor = _MutableVisitor(this, context);
    registry.addAnnotation(this, visitor);
  }
}

class _MutableVisitor extends SimpleAstVisitor<void> {
  _MutableVisitor(this.rule, this.context);
  final MutableRule rule;
  final RuleContext context;

  @override
  void visitAnnotation(Annotation node) {
    var enclosing = node.element?.enclosingElement;
    if (enclosing is! ClassElement) return;
    var parent = node.parent;
    if (parent is! ClassDeclaration) {
      // How can this be considering the above condition?
      return;
    }

    var object = node.elementAnnotation?.computeConstantValue();
    if (object == null) return;

    var crystallise = Crystallise.parser(object);
    var defaultConstructorConstKeyword = parent.defaultConstructorConst;
    var defaultConstructor = enclosing.constructors.singleWhereOrNull((c) => c.name == 'new');
    if (crystallise.mutable) {
      if (defaultConstructor != null && defaultConstructorConstKeyword != null) {
        rule.reportAtToken(diagnosticCode: CrystallisCode.constConstructor.code, defaultConstructorConstKeyword);
      } else if (defaultConstructor == null) {
        rule.reportAtToken(diagnosticCode: CrystallisCode.constConstructor.code, parent.namePart.typeName);
      }
      if (parent.finalFields.isNotEmpty) {
        for (var token in parent.finalFields) {
          rule.reportAtToken(diagnosticCode: CrystallisCode.immutableField.code, token);
        }
      }
    } else {
      var token = parent.defaultConstructorFirstEntity;
      if (defaultConstructor != null && defaultConstructorConstKeyword == null && token != null) {
        rule.reportAtToken(diagnosticCode: CrystallisCode.nonConstConstructor.code, token);
      } else if (defaultConstructor == null) {
        rule.reportAtToken(diagnosticCode: CrystallisCode.nonConstConstructor.code, parent.namePart.typeName);
      }
      for (var entity in parent.nonFinalFields) {
        switch (entity) {
          case Token token:
            rule.reportAtToken(diagnosticCode: CrystallisCode.mutableField.code, token);
          case AstNode node:
            rule.reportAtNode(diagnosticCode: CrystallisCode.mutableField.code, node);
        }
      }
    }
  }
}

extension on ClassDeclaration {
  Token? get defaultConstructorConst {
    var primary = switch (namePart) {
      PrimaryConstructorDeclaration(:var declaredFragment?) && var constructor
          when declaredFragment.element.isDefaultConstructor =>
        constructor,
      _ => null,
    };
    if (primary != null) return primary.constKeyword;
    var constructor = switch (body) {
      EmptyClassBody() => null,
      BlockClassBody(:final members) => members.whereType<ConstructorDeclaration>().singleWhereOrNull(
        (m) => m.declaredFragment?.element.isDefaultConstructor ?? false,
      ),
    };
    return constructor?.constKeyword;
  }

  Token? get defaultConstructorFirstEntity {
    var primary = switch (namePart) {
      PrimaryConstructorDeclaration(:var declaredFragment?) && var constructor
          when declaredFragment.element.isDefaultConstructor =>
        constructor,
      _ => null,
    };
    if (primary != null) return primary.typeName;
    var constructor = switch (body) {
      EmptyClassBody() => null,
      BlockClassBody(:final members) => members.whereType<ConstructorDeclaration>().singleWhereOrNull(
        (m) => m.declaredFragment?.element.isDefaultConstructor ?? false,
      ),
    };
    return constructor?.newKeyword ?? constructor?.typeName?.token ?? constructor?.name;
  }

  List<Token> get finalFields => _fields(isFinal: true).cast();

  List<SyntacticEntity> get nonFinalFields => _fields(isFinal: false);

  List<SyntacticEntity> _fields({required bool isFinal}) {
    var primary = switch (namePart) {
      PrimaryConstructorDeclaration(:var formalParameters) =>
        formalParameters.parameters
            .where((p) {
              if (p.declaredFragment?.element case FieldFormalParameterElement(isStatic: false)) {
                return (p.isFinal == isFinal);
              }
              return false;
            })
            .map((p) {
              if (p
                  case DefaultFormalParameter(parameter: SimpleFormalParameter parameter) ||
                      SimpleFormalParameter parameter) {
                return parameter.keyword;
              } else {
                return null;
              }
            })
            .nonNulls
            .toList(),
      _ => const <Token>[],
    };
    var fields = switch (this.body) {
      EmptyClassBody() => primary,
      BlockClassBody(:final members) => [
        ...primary,
        ...members
            .whereType<FieldDeclaration>()
            .where((f) => !f.isStatic && (f.fields.isFinal == isFinal))
            .map((f) => f.fields.keyword ?? f.fields.type!),
      ],
    };
    return fields;
  }
}
