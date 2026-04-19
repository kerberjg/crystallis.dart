import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:crystallis_plugin/src/rules/crystallis_rule.dart';
import 'package:crystallis_plugin/src/utils/annotation.dart';

/// {@template equals_rule}
/// This rule warns when a class annotated with @Crystallise(equals: true) already defines a == operator,
/// which causes the generator to skip generating one.
/// {@endtemplate}
class EqualsRule extends CrystallisRule {
  /// {@macro equals_rule}
  EqualsRule() : super(.equalsDefined);

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    var visitor = _EqualsVisitor(this, context);
    registry.addAnnotation(this, visitor);
  }
}

class _EqualsVisitor extends SimpleAstVisitor<void> {
  _EqualsVisitor(this.rule, this.context);
  final EqualsRule rule;
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
    if (!crystallise.enableEquals) return;

    var equalsOperator = switch (parent.body) {
      EmptyClassBody() => null,
      BlockClassBody(:final members) => members.whereType<MethodDeclaration>().firstWhereOrNull(
        (m) => !m.isStatic && m.isOperator && m.name.lexeme == '==',
      ),
    };
    if (equalsOperator == null) return;

    rule.reportAtToken(equalsOperator.name);
  }
}
