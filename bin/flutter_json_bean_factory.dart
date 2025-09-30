import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_json_bean_factory/src/config.dart';
import 'package:flutter_json_bean_factory/src/scan.dart';
import 'package:flutter_json_bean_factory/src/generate.dart';
import 'package:flutter_json_bean_factory/src/log.dart';

Future<int> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('project', abbr: 'p', help: 'Flutter project path (default: current directory)')
    ..addOption('gen-path', abbr: 'g', help: 'Generated files path under lib/ (default: generated/json)')
    ..addOption('model-suffix', abbr: 's', help: 'Model suffix for file naming (default: entity)')
    ..addOption('log-level', abbr: 'l', defaultsTo: 'info', allowed: ['error', 'warn', 'info', 'debug'], help: 'Log level')
    ..addFlag('help', abbr: 'h', defaultsTo: false, help: 'Show this help message');

  late ArgResults results;
  try {
    results = parser.parse(args);
  } catch (e) {
    stderr.writeln('Error: $e');
    stderr.writeln(parser.usage);
    return 1;
  }

  if (results.flag('help')) {
    stdout.writeln('Flutter JSON Bean Factory CLI');
    stdout.writeln('');
    stdout.writeln('Usage: dart run flutter_json_bean_factory [options]');
    stdout.writeln('');
    stdout.writeln(parser.usage);
    return 0;
  }

  // 自动检测项目路径：如果当前目录有 pubspec.yaml，就使用当前目录
  String projectPath = results.option('project') ?? '.';
  if (projectPath == '.') {
    final pubspec = File('pubspec.yaml');
    if (await pubspec.exists()) {
      projectPath = Directory.current.path;
    } else {
      stderr.writeln('Error: No pubspec.yaml found in current directory. Please specify --project path.');
      return 1;
    }
  }

  final project = p.normalize(p.absolute(projectPath));
  final cfg = await loadConfig(
    projectPath: project,
    genPathOverride: results.option('gen-path'),
    modelSuffixOverride: results.option('model-suffix'),
    logLevel: parseLogLevel(results.option('log-level')!),
  );

  try {
    final entities = await scanEntities(cfg);
    await generateAll(cfg, entities);
    return 0;
  } catch (e, st) {
    logError('Failed: $e\n$st', cfg.logLevel);
    return 1;
  }
}
