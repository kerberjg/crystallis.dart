import 'dart:io';
import 'dart:isolate';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:crystallis_generator/crystallis_generator.dart';
import 'package:path/path.dart';

final _crystallisGeneratorUri = Uri.parse('package:crystallis_generator/crystallis_generator.dart');

Future<Directory> getPackageRoot() async {
  var uri = await Isolate.resolvePackageUri(_crystallisGeneratorUri);
  if (uri == null) {
    // Should never happen unless we change the package or file name.
    throw StateError('Could not resolve package URI for crystallis_generator.');
  }
  return File(uri.toFilePath()).parent.parent;
}

Future<(String, String)> generateIntegration(String inputFile, String outputFile, {bool write = false}) async {
  const outputPackage = 'test_pkg';
  final builder = crystallisBuilder(const BuilderOptions({}, isRoot: true));

  final rw = TestReaderWriter(rootPackage: outputPackage);
  await rw.testing.loadIsolateSources();

  var packageRoot = await getPackageRoot();
  final result = await testBuilder(
    builder,
    {
      '$outputPackage|test/generated_test_structure.dart': File(
        join(packageRoot.path, 'test', 'integration', inputFile),
      ).readAsStringSync(),
    },
    outputs: null,
    readerWriter: rw,
    flattenOutput: true,
  );
  var generatedFilePath = join(packageRoot.path, 'test', 'integration', 'generated', outputFile);
  var generatedFile = File(generatedFilePath);

  var output = rw.testing
      .readString(result.outputs.first)
      .replaceFirst('asset:test_pkg/test/generated_test_structure.dart', '../$inputFile');
  
  if (write) {
    if (generatedFile.existsSync()) {
      generatedFile.deleteSync();
    }
    generatedFile.createSync(recursive: true);
    generatedFile.writeAsStringSync(output);
  }

  return (generatedFilePath, output);
}
