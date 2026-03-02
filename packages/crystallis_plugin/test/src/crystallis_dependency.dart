import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

mixin CrystallisDependency on AnalysisRuleTest {
  static final _regExp = RegExp('/');

  Future<PackageBuilder> addCrystallisDependency() async{
    var directory = await _getCrystallisPackageDirectory();
    var resourceProvider = PhysicalResourceProvider.INSTANCE;
    var crystallisLibSource = resourceProvider.getFolder(
      resourceProvider.pathContext.normalize(join(directory.uri.toFilePath(), 'lib')),
    );

    var annotationFolder = newFolder('/package/crystallis');
    crystallisLibSource.copyTo(annotationFolder);

    return newPackage('crystallis');
  }

  Future<Directory> _getCrystallisPackageDirectory() async {
    return await _packageDir('crystallis', 'crystallis.dart');
  }

  /// Utility functions to get the file system paths of the given package.
  Future<Directory> _packageDir(String packageName, String fileUnderLib) async {
    var packageUri = Uri.parse('package:$packageName/$fileUnderLib');
    var uri = await Isolate.resolvePackageUri(packageUri);

    if (uri == null) {
      throw StateError('Could not resolve package URI for $packageName.');
    }
    var dir = Directory(uri.toFilePath());
    for (var _ in _regExp.allMatches(fileUnderLib)) {
      dir = dir.parent;
    }
    //          <lib>.<root>
    return dir.parent.parent;
  }
}
