import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'log.dart';

class Config {
  Config({
    required this.projectPath,
    required this.packageName,
    required this.genPath,
    required this.modelSuffix,
    required this.logLevel,
  });

  final String projectPath;
  final String packageName;
  final String genPath; // relative under lib/
  final String modelSuffix; // suffix for model files
  final LogLevel logLevel;

  Directory get projectDir => Directory(projectPath);
  Directory get libDir => Directory(p.join(projectPath, 'lib'));
  Directory get genBaseDir => Directory(p.join(projectPath, 'lib', genPath, 'base'));
}

Future<Config> loadConfig({
  required String projectPath,
  String? genPathOverride,
  String? modelSuffixOverride,
  required LogLevel logLevel,
}) async {
  final pubspec = File(p.join(projectPath, 'pubspec.yaml'));
  var packageName = p.basename(projectPath);
  var genPath = 'generated/json';
  var modelSuffix = 'entity';

  if (await pubspec.exists()) {
    final content = await pubspec.readAsString();
    try {
      final map = loadYaml(content) as Map;
      packageName = (map['name'] ?? packageName).toString();
      final fj = map['flutter_json'] as Map?;
      if (fj != null) {
        if (fj['generated_path'] != null) {
          genPath = fj['generated_path'].toString();
        }
        if (fj['model_suffix'] != null) {
          modelSuffix = fj['model_suffix'].toString();
        }
      }
    } catch (_) {}
  }

  // 命令行参数覆盖配置文件
  if (genPathOverride != null && genPathOverride.isNotEmpty) {
    genPath = genPathOverride;
  }
  if (modelSuffixOverride != null && modelSuffixOverride.isNotEmpty) {
    modelSuffix = modelSuffixOverride;
  }

  return Config(
    projectPath: projectPath,
    packageName: packageName,
    genPath: genPath,
    modelSuffix: modelSuffix,
    logLevel: logLevel,
  );
}
