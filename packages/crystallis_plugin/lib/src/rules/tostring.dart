import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:crystallis_plugin/src/rules/crystallis_rule.dart';
import 'package:crystallis_plugin/src/utils/annotation.dart';

/// {@template tostring_rule}
/// This rule warns when a class annotated with @Crystallise(enableToString: true) already defines a toString()
/// method, which causes the generator to skip generating one.
/// {@endtemplate}
class ToStringRule extends CrystallisRule {
  /// {@macro tostring_rule}
  ToStringRule() : super(.toStringDefined);

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    var visitor = _ToStringVisitor(this, context);
    registry.addAnnotation(this, visitor);
  }
}

class _ToStringVisitor extends SimpleAstVisitor<void> {
  _ToStringVisitor(this.rule, this.context);
  final ToStringRule rule;
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
    if (!crystallise.enableToString) return;

    var toStringMethod = switch (parent.body) {
      EmptyClassBody() => null,
      BlockClassBody(:final members) => members.whereType<MethodDeclaration>().firstWhereOrNull(
        (m) => !m.isStatic && m.name.lexeme == 'toString',
      ),
    };
    if (toStringMethod == null) return;

    rule.reportAtToken(toStringMethod.name, arguments: [parent.namePart.typeName.lexeme]);
  }
}
