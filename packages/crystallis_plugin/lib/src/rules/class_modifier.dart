import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:crystallis_plugin/src/rules/crystallis_code.dart';
import 'package:crystallis_plugin/src/rules/crystallis_rule.dart';
import 'package:crystallis_plugin/src/utils/annotation.dart';

/// An enumeration of all codes for the [ClassModifierRule]. This rule checks for classes annotated with @Crystallise
/// that are sealed, final, or have a private name, as no subclasses can be generated for them.
enum ClassModifierCode with CrystallisCodeMixin {
  /// Checks for classes annotated with @Crystallise that are sealed, as no subclasses can be generated for them.
  sealed_(
    CrystallisLintCode.generatorMessages(
      ruleFlag: .classModifier,
      severity: .ERROR,
      uniqueName: 'crystallis_sealed_class',
      problemMessage: .classIsSealed,
      correctionMessage:
          "Consider removing the 'sealed' modifier from the class declaration or removing the @Crystallise annotation.",
    ),
  ),

  /// Checks for classes annotated with @Crystallise that are final, as no subclasses can be generated for them.
  final_(
    CrystallisLintCode.generatorMessages(
      ruleFlag: .classModifier,
      severity: .ERROR,
      uniqueName: 'crystallis_final_class',
      problemMessage: .classIsFinal,
      correctionMessage:
          "Consider removing the 'final' modifier from the class declaration or removing the @Crystallise annotation.",
    ),
  ),

  /// Checks for classes annotated with @Crystallise that have a private name, as no subclasses can be generated for
  /// them.
  private(
    CrystallisLintCode.generatorMessages(
      ruleFlag: .classModifier,
      severity: .ERROR,
      uniqueName: 'crystallis_private_class',
      problemMessage: .classIsPrivate,
      correctionMessage: 'Consider making the class name public or removing the @Crystallise annotation.',
    ),
  );

  const ClassModifierCode(this.code);

  /// The [CrystallisRuleFlag] associated with these codes, used to determine which rule to report for.
  static const CrystallisRuleFlag flag = .classModifier;

  /// The [CrystallisLintCode] associated with this rule. This contains the details of the rule, such as the name,
  /// description, problem message, and correction message.
  @override
  final CrystallisLintCode code;
}

/// {@template class_modifier_rule}
/// This rule warns when a class annotated with @Crystallise is sealed, final, or has a private name,
/// as the generator cannot produce a part file for such classes.
/// {@endtemplate}
class ClassModifierRule extends MutltiCrystallisRule<ClassModifierCode> {
  /// {@macro class_modifier_rule}
  ClassModifierRule() : super(ClassModifierCode.flag);

  @override
  List<ClassModifierCode> get codes => ClassModifierCode.values;

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

    if (enclosing.isSealed) {
      rule.reportCodeAtNode(node, diagnosticCode: .sealed_);
    } else if (enclosing.isFinal) {
      rule.reportCodeAtNode(node, diagnosticCode: .final_);
    } else if (enclosing.isPrivate) {
      rule.reportCodeAtNode(node, diagnosticCode: .private);
    }
  }
}
