import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:crystallis_plugin/src/rules/crystallis_rule.dart';
import 'package:crystallis_plugin/src/utils/annotation.dart';

/// {@template mutable_rule}
/// This rule checks for mutable fields in classes annotated with @Crystallis(mutable: false). It ensures that all
/// fields in such classes are final.
/// {@endtemplate}
class MutableRule extends CrystallisRule {
  /// {@macro mutable_rule}
  MutableRule() : super(.mutable);

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
        rule.reportAtToken(defaultConstructorConstKeyword);
      } else if (defaultConstructor == null) {
        rule.reportAtToken(parent.namePart.typeName);
      }
      if (parent.finalFields.isNotEmpty) {
        for (var token in parent.finalFields) {
          rule.reportAtToken(token);
        }
      }
    } else {
      if (defaultConstructor != null && defaultConstructorConstKeyword == null) {
        rule.reportAtToken(parent.namePart.typeName);
      } else if (defaultConstructor == null) {
        rule.reportAtToken(parent.namePart.typeName);
      }
      for (var entity in parent.nonFinalFields) {
        switch (entity) {
          case Token token:
            rule.reportAtToken(token);
          case AstNode node:
            rule.reportAtNode(node);
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

  List<Token> get finalFields {
    var body = switch (this.body) {
      EmptyClassBody() => null,
      BlockClassBody(:final members) => members,
    };
    if (body == null) return const [];
    return body
        .whereType<FieldDeclaration>()
        .where((f) => !f.isStatic && f.fields.isFinal)
        .map((f) => f.fields.keyword!)
        .toList();
  }

  List<SyntacticEntity> get nonFinalFields {
    var body = switch (this.body) {
      EmptyClassBody() => null,
      BlockClassBody(:final members) => members,
    };
    if (body == null) return const [];
    return body
        .whereType<FieldDeclaration>()
        .where((f) => !f.isStatic && !f.fields.isFinal)
        .map((f) => f.fields.keyword ?? f.fields.type!)
        .toList();
  }
}
