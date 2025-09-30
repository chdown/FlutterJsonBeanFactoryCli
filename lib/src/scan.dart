import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'log.dart';
import 'types.dart';

Future<List<EntitySource>> scanEntities(Config cfg) async {
  final lib = cfg.libDir;
  if (!await lib.exists()) {
    logWarn('[warn] lib/ not found; nothing to do', cfg.logLevel);
    return [];
  }

  final contexts = AnalysisContextCollection(includedPaths: [lib.path]);
  final entities = <EntitySource>[];

  for (final ctx in contexts.contexts) {
    final files = ctx.contextRoot.analyzedFiles().where((p0) => p0.endsWith('.dart'));
    for (final filePath in files) {
      final rel = p.relative(filePath, from: cfg.projectPath).replaceAll('\\', '/');
      if (_excluded(rel, cfg)) continue;
      final unitResult = await ctx.currentSession.getResolvedUnit(filePath);
      if (unitResult is! ResolvedUnitResult) continue;
      // include only when annotated: fixed to JsonSerializable/JSONField
      if (!_containsIncludedAnnotations(unitResult, const ['JsonSerializable', 'JSONField'])) {
        continue;
      }
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
  logInfo('[info] scanned ${entities.length} Dart sources with classes', cfg.logLevel);
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

bool _containsIncludedAnnotations(ResolvedUnitResult unit, List<String> include) {
  if (include.isEmpty) return true; // no filter
  final CompilationUnit cu = unit.unit;
  bool has = false;
  void checkNode(AnnotatedNode node) {
    for (final meta in node.metadata) {
      final id = meta.name;
      final name = id.name;
      if (include.contains(name)) {
        has = true;
        return;
      }
    }
  }

  for (final decl in cu.declarations) {
    if (decl is ClassDeclaration) {
      checkNode(decl);
      if (has) return true;
      for (final m in decl.members) {
        if (m is FieldDeclaration) {
          checkNode(m);
          if (has) return true;
        }
      }
    } else if (decl is TopLevelVariableDeclaration) {
      checkNode(decl);
      if (has) return true;
    }
  }
  return false;
}
