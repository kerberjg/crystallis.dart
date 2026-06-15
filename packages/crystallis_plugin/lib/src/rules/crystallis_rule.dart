import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/pubspec.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:crystallis_plugin/src/rules/crystallis_code.dart';
import 'package:meta/meta.dart';

/// An enumeration of all the rules that the Crystallis plugin provides. Each rule has at least one corresponding
/// [CrystallisLintCode] that will be reported when the rule is violated.
enum CrystallisRuleFlag {
  /// {@macro mutability_rule}
  mutability(
    name: 'mutability',
    description:
        'This rule checks for mutable fields in classes annotated with @Crystallise to make sure they align with '
        "whatever 'mutable' value they were defined.",
    lint: false,
  ),

  /// {@macro equals_rule}
  equals(
    name: 'equals',
    description:
        'This rule checks for == operators manually defined in classes annotated with @Crystallise '
        'when equals generation is enabled, as the generator will skip generation in that case.',
  ),

  /// {@macro tostring_rule}
  tostring(
    name: 'tostring',
    description:
        'This rule checks for toString() methods manually defined in classes annotated with @Crystallise '
        'when toString generation is enabled, as the generator will skip generation in that case.',
    lint: false,
  ),

  /// {@macro hashcode_rule}
  hashcode(
    name: 'hashcode',
    description:
        'This rule checks for hashCode getters manually defined in classes annotated with @Crystallise '
        'when hashCode generation is enabled, as the generator will skip generation in that case.',
    lint: false,
  ),

  /// {@macro class_modifier_rule}
  classModifier(
    name: 'class_modifier',
    description:
        'This rule checks for classes annotated with @Crystallise that are sealed, final, or have a private name, '
        'as no subclasses can be generated for them.',
    lint: false,
  );

  const CrystallisRuleFlag({required this.name, required this.description, this.lint = true});

  /// A human-readable name for the rule, used in the insights page and similar.
  final String name;

  /// A human-readable description of the rule that is being violated, used in the insights page and similar.
  final String description;

  /// Whether this rule should be enabled by the user or if it would be enabled regardless of user configuration. This
  /// is useful for rules that are critical to the workings of the package.
  final bool lint;

  @override
  String toString() => name;
}

/// A mixin that provides a common interface for both single and multi code rules.
mixin CrystallisCodeMixin on Enum {
  /// The [CrystallisLintCode] associated with this rule. This contains the details of the rule, such as the name,
  /// description, problem message, and correction message.
  CrystallisLintCode get code;
}

/// {@template crystallis_rule}
/// A base class for all analysis rules provided by the Crystallis plugin. Each rule checks for a specific violation of
/// the Crystallis annotations and provides a corresponding diagnostic code.
/// {@endtemplate}
abstract class CrystallisRule extends AnalysisRule {
  /// {@macro crystallis_rule}
  CrystallisRule(CrystallisCode code)
    : diagnosticCode = code.code,
      super(name: code.name, description: code.code.description);

  @override
  final CrystallisLintCode diagnosticCode;

  @override
  @mustBeOverridden
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context);
}

/// {@template multi_crystallis_rule}
/// A base class for analysis rules that need to produce multiple diagnostics. This is useful for rules that need to
/// check different but related things.
/// {@endtemplate}
abstract class MutltiCrystallisRule<TCrystallisCode extends CrystallisCodeMixin> extends MultiAnalysisRule {
  /// {@macro multi_crystallis_rule}
  MutltiCrystallisRule(this.ruleFlag) : super(name: ruleFlag.name, description: ruleFlag.description);

  @override
  List<CrystallisLintCode> get diagnosticCodes => codes.map((c) => c.code).toList();

  /// The rule flag associated with this rule, used to determine which diagnostics to report.
  final CrystallisRuleFlag ruleFlag;

  /// A list of all the [CrystallisLintCode]s that this rule can report. This is used to register the codes with the
  /// server.
  List<TCrystallisCode> get codes;

  @override
  @mustBeOverridden
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context);

  @override
  @Deprecated('Use reportCodeAtNode instead')
  Diagnostic? reportAtNode(
    AstNode? node, {
    List<Object> arguments = const [],
    List<DiagnosticMessage>? contextMessages,
    required DiagnosticCode diagnosticCode,
  }) =>
      super.reportAtNode(node, diagnosticCode: diagnosticCode, arguments: arguments, contextMessages: contextMessages);

  @override
  @Deprecated('Use reportCodeAtOffset instead')
  Diagnostic reportAtOffset(
    int offset,
    int length, {
    required DiagnosticCode diagnosticCode,
    List<Object> arguments = const [],
    List<DiagnosticMessage>? contextMessages,
  }) => super.reportAtOffset(
    offset,
    length,
    diagnosticCode: diagnosticCode,
    arguments: arguments,
    contextMessages: contextMessages,
  );

  @override
  @Deprecated('Use reportCodeAtPubNode instead')
  Diagnostic reportAtPubNode(
    PubspecNode node, {
    required DiagnosticCode diagnosticCode,
    List<Object> arguments = const [],
    List<DiagnosticMessage> contextMessages = const [],
  }) => super.reportAtPubNode(
    node,
    diagnosticCode: diagnosticCode,
    arguments: arguments,
    contextMessages: contextMessages,
  );

  @override
  @Deprecated('Use reportCodeAtSourceRange instead')
  Diagnostic reportAtSourceRange(
    SourceRange sourceRange, {
    required DiagnosticCode diagnosticCode,
    List<Object> arguments = const [],
    List<DiagnosticMessage>? contextMessages,
  }) => super.reportAtSourceRange(
    sourceRange,
    diagnosticCode: diagnosticCode,
    arguments: arguments,
    contextMessages: contextMessages,
  );

  @override
  @Deprecated('Use reportCodeAtToken instead')
  Diagnostic? reportAtToken(
    Token token, {
    required DiagnosticCode diagnosticCode,
    List<Object> arguments = const [],
    List<DiagnosticMessage>? contextMessages,
  }) => super.reportAtToken(
    token,
    diagnosticCode: diagnosticCode,
    arguments: arguments,
    contextMessages: contextMessages,
  );

  // ignore: deprecated_member_use_from_same_package
  /// The same as [reportAtNode] but with a non-deprecated API. This is used to report diagnostics for this rule.
  Diagnostic? reportCodeAtNode(
    AstNode? node, {
    List<Object> arguments = const [],
    List<DiagnosticMessage>? contextMessages,
    required TCrystallisCode diagnosticCode,
  }) => super.reportAtNode(
    node,
    diagnosticCode: diagnosticCode.code,
    arguments: arguments,
    contextMessages: contextMessages,
  );

  // ignore: deprecated_member_use_from_same_package
  /// The same as [reportAtOffset] but with a non-deprecated API. This is used to report diagnostics for this rule.
  Diagnostic reportCodeAtOffset(
    int offset,
    int length, {
    required TCrystallisCode diagnosticCode,
    List<Object> arguments = const [],
    List<DiagnosticMessage>? contextMessages,
  }) => super.reportAtOffset(
    offset,
    length,
    diagnosticCode: diagnosticCode.code,
    arguments: arguments,
    contextMessages: contextMessages,
  );

  // ignore: deprecated_member_use_from_same_package
  /// The same as [reportAtPubNode] but with a non-deprecated API. This is used to report diagnostics for this rule.
  Diagnostic reportCodeAtPubNode(
    PubspecNode node, {
    required TCrystallisCode diagnosticCode,
    List<Object> arguments = const [],
    List<DiagnosticMessage> contextMessages = const [],
  }) => super.reportAtPubNode(
    node,
    diagnosticCode: diagnosticCode.code,
    arguments: arguments,
    contextMessages: contextMessages,
  );

  // ignore: deprecated_member_use_from_same_package
  /// The same as [reportAtSourceRange] but with a non-deprecated API. This is used to report diagnostics for this rule.
  Diagnostic reportCodeAtSourceRange(
    SourceRange sourceRange, {
    required TCrystallisCode diagnosticCode,
    List<Object> arguments = const [],
    List<DiagnosticMessage>? contextMessages,
  }) => super.reportAtSourceRange(
    sourceRange,
    diagnosticCode: diagnosticCode.code,
    arguments: arguments,
    contextMessages: contextMessages,
  );

  // ignore: deprecated_member_use_from_same_package
  /// The same as [reportAtToken] but with a non-deprecated API. This is used to report diagnostics for this rule.
  Diagnostic? reportCodeAtToken(
    Token token, {
    required TCrystallisCode diagnosticCode,
    List<Object> arguments = const [],
    List<DiagnosticMessage>? contextMessages,
  }) => super.reportAtToken(
    token,
    diagnosticCode: diagnosticCode.code,
    arguments: arguments,
    contextMessages: contextMessages,
  );
}
