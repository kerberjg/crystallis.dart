import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

/// The plugin class that implements the analysis server plugin interface. This is where we will register our analysis
/// rules, quick fixes, and quick assists.
class CrystallisPlugin extends Plugin {
  @override
  String get name => 'Simple plugin';

  @override
  void register(PluginRegistry registry) {
    
  }
}
