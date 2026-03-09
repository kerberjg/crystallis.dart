import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'src/integration.dart';

Future<void> main() async {
  var packageRoot = await getPackageRoot();
  var integrationFolder = Directory(path.join(packageRoot.path, 'test', 'integration'));
  var allFiles = integrationFolder.listSync().whereType<File>().toList();

  group('generated', () {
    var files = allFiles.where((f) => f.path.endsWith('_test.dart')).toList();
    group('files', () {
      for (final file in files) {
        var fileName = path.basename(file.path);
        test(fileName, () async {
          var outputFileName = fileName.replaceFirst('_test.dart', '.dart');
          print('Generating for $fileName...');
          var (path, content) = await generateIntegration(fileName, outputFileName);
          var generatedFile = File(path);
          expect(generatedFile.existsSync(), isTrue, reason: 'Generated file does not exist at expected path: $path');
          expect(
            generatedFile.readAsStringSync(),
            equals(content),
            reason:
                'Generated file content does not match expected content for $fileName. Re-run the generator to update '
                'the expected content if the changes are intentional.',
          );
        });
      }
    });
  });
  test('No .g.dart', () {
    var gFiles = allFiles.where((file) => file.path.endsWith('.g.dart')).toList();
    expect(
      gFiles,
      isEmpty,
      reason:
          "There should be no '*.g.dart' files in the integration test folder, but found: \n"
          '- ${gFiles.map((f) => f.path).join(',\n- ')}',
    );
  });
}
