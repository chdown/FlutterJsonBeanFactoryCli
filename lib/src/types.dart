import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/results.dart';

class FieldInfo {
  FieldInfo({
    required this.name,
    required this.type,
    required this.isNullable,
    required this.isList,
    required this.elemType,
    this.jsonKeyName,
    this.serialize,
    this.deserialize,
    this.isEnum,
  });

  final String name;
  final String type; // maybe with ?
  final bool isNullable;
  final bool isList;
  final String? elemType;
  final String? jsonKeyName;
  final bool? serialize;
  final bool? deserialize;
  final bool? isEnum;
}

class ClassInfo {
  ClassInfo({required this.name, required this.fields, required this.hasJsonSerializable});
  final String name;
  final List<FieldInfo> fields;
  final bool hasJsonSerializable;
}

class EntitySource {
  EntitySource({
    required this.absolutePath,
    required this.relativePathUnderLib,
    required this.classes,
    required this.imports,
  });

  final String absolutePath;
  final String relativePathUnderLib;
  final List<ClassInfo> classes;
  final List<String> imports; // raw import directives (e.g., "import '...';"), from source file
}

class ParsedUnit {
  ParsedUnit(this.classes);
  final List<ClassInfo> classes;
}

ParsedUnit extractClasses(ResolvedUnitResult unit) {
  final classes = <ClassInfo>[];
  for (final decl in unit.unit.declarations) {
    if (decl is ClassDeclaration) {
      bool hasJsonSerializable = false;
      for (final meta in decl.metadata) {
        final id = meta.name;
        final n = id.name;
        if (n == 'JsonSerializable') {
          hasJsonSerializable = true;
          break;
        }
      }
      final fields = <FieldInfo>[];
      for (final member in decl.members) {
        if (member is FieldDeclaration) {
          final typeNode = member.fields.type;
          final typeStr = typeNode?.toSource() ?? 'dynamic';
          final isList = typeStr.startsWith('List<') || typeStr == 'List';
          final isNullable = typeStr.trim().endsWith('?');
          // parse @JSONField on field for name/serialize/deserialize
          String? jsonKeyName;
          bool? serialize;
          bool? deserialize;
          bool? isEnum;
          for (final meta in member.metadata) {
            final id = meta.name;
            final name = id.name;
            if (name == 'JSONField') {
              final args = meta.arguments;
              if (args != null) {
                for (final expr in args.arguments) {
                  if (expr is NamedExpression) {
                    final label = expr.name.label.name;
                    if (label == 'name' && expr.expression is StringLiteral) {
                      final s = (expr.expression as StringLiteral).stringValue;
                      if (s != null && s.isNotEmpty) jsonKeyName = s;
                    } else if (label == 'serialize' && expr.expression is BooleanLiteral) {
                      serialize = (expr.expression as BooleanLiteral).value;
                    } else if (label == 'deserialize' && expr.expression is BooleanLiteral) {
                      deserialize = (expr.expression as BooleanLiteral).value;
                    } else if (label == 'isEnum' && expr.expression is BooleanLiteral) {
                      isEnum = (expr.expression as BooleanLiteral).value;
                    }
                  }
                }
              }
            }
          }
          String? elem;
          if (isList) {
            final src = typeStr.replaceAll(' ', '');
            final start = src.indexOf('<');
            final end = src.lastIndexOf('>');
            if (start >= 0 && end > start) {
              elem = src.substring(start + 1, end).replaceAll('?', '');
            }
          }
          for (final v in member.fields.variables) {
            final name = v.name.lexeme;
            fields.add(FieldInfo(
              name: name,
              type: typeStr,
              isNullable: isNullable,
              isList: isList,
              elemType: elem,
              jsonKeyName: jsonKeyName,
              serialize: serialize,
              deserialize: deserialize,
              isEnum: isEnum,
            ));
          }
        }
      }
      // 只要类有 @JsonSerializable 注解就添加，不管是否有字段
      if (hasJsonSerializable) {
        classes.add(ClassInfo(name: decl.name.lexeme, fields: fields, hasJsonSerializable: hasJsonSerializable));
      }
    }
  }
  return ParsedUnit(classes);
}
