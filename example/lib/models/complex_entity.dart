import 'package:example/generated/json/base/json_field.dart';
import 'package:example/generated/json/complex_entity.g.dart';
import 'package:example/models/user_entity.dart';
import 'dart:convert';

@JsonSerializable()
class ComplexEntity {
  ComplexEntity();

  // 测试 Map 的值是实体类
  Map<String, UserEntity>? userMap;

  // 测试 List 的元素是 Map
  List<Map<String, dynamic>>? dataList;

  // 测试特殊字符的 Key
  @JSONField(name: "kebab-case-key")
  String? kebabCase;

  // 测试 DateTime (通常作为 String 处理，验证生成逻辑)
  DateTime? createdAt;

  // 测试 List of List (当前插件可能不支持，验证其行为)
  // List<List<int>>? matrix; 
  // 暂时注释掉，因为 types.dart 的解析逻辑似乎不支持嵌套泛型 List<List<...>>

  factory ComplexEntity.fromJson(Map<String, dynamic> json) => $ComplexEntityFromJson(json);
  Map<String, dynamic> toJson() => $ComplexEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
