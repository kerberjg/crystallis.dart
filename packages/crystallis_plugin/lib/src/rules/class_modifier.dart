import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:crystallis_plugin/src/rules/crystallis_rule.dart';
import 'package:crystallis_plugin/src/utils/annotation.dart';

/// {@template class_modifier_rule}
/// This rule warns when a class annotated with @Crystallise is sealed, final, or has a private name,
/// as the generator cannot produce a part file for such classes.
/// {@endtemplate}
class ClassModifierRule extends CrystallisRule {
  /// {@macro class_modifier_rule}
  ClassModifierRule() : super(.unsupportedClassModifier);

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    var visitor = _ClassModifierVisitor(this, context);
    registry.addAnnotation(this, visitor);
  }
}

class _ClassModifierVisitor extends SimpleAstVisitor<void> {
  _ClassModifierVisitor(this.rule, this.context);
  final ClassModifierRule rule;
  final RuleContext context;

  @override
  void visitAnnotation(Annotation node) {
    var parent = node.parent;
    if (parent is! ClassDeclaration) return;
    var enclosing = parent.declaredFragment?.element;
    if (enclosing is! ClassElement) return;

    var object = node.elementAnnotation?.computeConstantValue();
    if (object == null) return;
    if (!Crystallise.isCrystalliseAnnotation(object)) return;

    if (!enclosing.isSealed && !enclosing.isFinal && !enclosing.isPrivate) return;

    rule.reportAtNode(node);
  }
}
