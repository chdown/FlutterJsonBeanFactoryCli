import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'log.dart';
import 'types.dart';

Future<List<EntitySource>> scanEntities(Config cfg) async {
  final startTime = DateTime.now();
  final lib = cfg.libDir;
  if (!await lib.exists()) {
    logWarn('[warn] lib/ not found; nothing to do', cfg.logLevel);
    return [];
  }

  final contexts = AnalysisContextCollection(includedPaths: [lib.path]);
  final entities = <EntitySource>[];
  int processedFiles = 0;

  for (final ctx in contexts.contexts) {
    final files = ctx.contextRoot.analyzedFiles().where((p0) => p0.endsWith('.dart'));

    // 优化：快速预筛选包含目标注解的文件
    final quickCheckStartTime = DateTime.now();
    final filesWithAnnotations = <String>[];

    // 并行快速检测文件内容
    final quickCheckFutures = files.map((filePath) async {
      final rel = p.relative(filePath, from: cfg.projectPath).replaceAll('\\', '/');
      if (_excluded(rel, cfg)) return null;

      try {
        if (await _hasTargetAnnotations(filePath)) {
          return filePath;
        }
        return null;
      } catch (e) {
        return null;
      }
    }).toList();

    final quickCheckResults = await Future.wait(quickCheckFutures);
    for (final result in quickCheckResults) {
      if (result != null) {
        filesWithAnnotations.add(result);
      }
    }

    final quickCheckEndTime = DateTime.now();
    final quickCheckDuration = quickCheckEndTime.difference(quickCheckStartTime);
    final quickCheckSeconds = quickCheckDuration.inMilliseconds / 1000.0;

    logInfo('[info] quick annotation check: ${filesWithAnnotations.length} files contain target annotations in ${quickCheckSeconds.toStringAsFixed(2)}s',
        cfg.logLevel);

    // 只对包含注解的文件进行 AST 解析
    for (final filePath in filesWithAnnotations) {
      final rel = p.relative(filePath, from: cfg.projectPath).replaceAll('\\', '/');
      processedFiles++;
      final unitResult = await ctx.currentSession.getResolvedUnit(filePath);
      if (unitResult is! ResolvedUnitResult) continue;

      // 优化：跳过重复注解检查，直接提取类
      final parsed = extractClasses(unitResult);
      if (parsed.classes.isEmpty) continue;
      // Only keep classes that are annotated with @JsonSerializable or having fields with @JSONField
      final filtered = parsed.classes.where((c) => c.hasJsonSerializable).toList();
      if (filtered.isEmpty) continue;
      final relUnderLib = rel.split('lib/').length > 1 ? rel.split('lib/')[1] : rel;
      final imports = _collectImports(unitResult);
      entities.add(EntitySource(
        absolutePath: filePath,
        relativePathUnderLib: relUnderLib,
        classes: filtered,
        imports: imports,
      ));
    }
  }

  entities.sort((a, b) => a.relativePathUnderLib.compareTo(b.relativePathUnderLib));

  final endTime = DateTime.now();
  final duration = endTime.difference(startTime);
  final durationSeconds = duration.inMilliseconds / 1000.0;

  logInfo('[info] scan completed: ${entities.length} entities from $processedFiles files in ${durationSeconds.toStringAsFixed(2)}s', cfg.logLevel);
  return entities;
}

List<String> _collectImports(ResolvedUnitResult unit) {
  final cu = unit.unit;
  final result = <String>[];
  for (final d in cu.directives) {
    if (d is ImportDirective) {
      result.add(d.toSource());
    }
  }
  return result;
}

bool _excluded(String rel, Config cfg) {
  final norm = rel.replaceAll('\\', '/');
  if (norm.contains('freezed')) return true;
  if (norm.endsWith('.g.dart')) return true;
  if (norm.startsWith('lib/${cfg.genPath}/')) return true;
  return false;
}

/// 快速检测文件是否包含目标注解，避免完整 AST 解析
Future<bool> _hasTargetAnnotations(String filePath) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) return false;

    // 读取文件内容进行快速字符串搜索
    final content = await file.readAsString();

    // 检查是否包含目标注解
    return content.contains('@JsonSerializable') || content.contains('@JSONField');
  } catch (e) {
    // 如果读取失败，返回 false，让后续处理决定
    return false;
  }
}
