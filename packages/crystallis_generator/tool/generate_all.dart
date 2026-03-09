import 'dart:io';

import 'package:path/path.dart';

import '../test/src/integration.dart';

Future<void> main() async {
  var packageRoot = await getPackageRoot();
  var integrationFolder = Directory(join(packageRoot.path, 'test', 'integration'));
  var files = <String>[];
  for (final file in integrationFolder.listSync().whereType<File>()) {
    if (file.path.endsWith('_test.dart')) {
      files.add(file.path);
    }
  }
  for (final file in files) {
    var fileName = basename(file);
    var outputFileName = fileName.replaceFirst('_test.dart', '.dart');
    print('Generating for $fileName...');
    await generateIntegration(fileName, outputFileName, write: true);
  }
}
