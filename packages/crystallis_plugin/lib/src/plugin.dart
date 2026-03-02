import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:crystallis_plugin/src/plugin_integration.dart';

/// The plugin class that implements the analysis server plugin interface. This is where we will register our analysis
/// rules, quick fixes, and quick assists.
class CrystallisPlugin extends Plugin with RulesMixin {
  @override
  String get name => 'Crystallis plugin';

  @override
  void register(PluginRegistry registry) {
    registerRules(registry.registerLintRule);
  }
}
