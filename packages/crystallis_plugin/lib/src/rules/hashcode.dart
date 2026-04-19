import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:crystallis_plugin/src/rules/crystallis_rule.dart';
import 'package:crystallis_plugin/src/utils/annotation.dart';

/// {@template hashcode_rule}
/// This rule warns when a class annotated with @Crystallise(hashCode: true) already defines a hashCode getter,
/// which causes the generator to skip generating one.
/// {@endtemplate}
class HashCodeRule extends CrystallisRule {
  /// {@macro hashcode_rule}
  HashCodeRule() : super(.hashCodeDefined);

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    var visitor = _HashCodeVisitor(this, context);
    registry.addAnnotation(this, visitor);
  }
}

class _HashCodeVisitor extends SimpleAstVisitor<void> {
  _HashCodeVisitor(this.rule, this.context);
  final HashCodeRule rule;
  final RuleContext context;

  @override
  void visitAnnotation(Annotation node) {
    var enclosing = node.element?.enclosingElement;
    if (enclosing is! ClassElement) return;
    var parent = node.parent;
    if (parent is! ClassDeclaration) return;

    var object = node.elementAnnotation?.computeConstantValue();
    if (object == null) return;
    if (!Crystallise.isCrystalliseAnnotation(object)) return;

    var crystallise = Crystallise.parser(object);
    if (!crystallise.enableHashCode) return;

    var hashCodeGetter = switch (parent.body) {
      EmptyClassBody() => null,
      BlockClassBody(:final members) => members.whereType<MethodDeclaration>().firstWhereOrNull(
        (m) => !m.isStatic && m.isGetter && m.name.lexeme == 'hashCode',
      ),
    };
    if (hashCodeGetter == null) return;

    rule.reportAtToken(hashCodeGetter.name);
  }
}
