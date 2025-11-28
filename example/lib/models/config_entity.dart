import 'package:example/generated/json/base/json_field.dart';
import 'dart:convert';

import 'package:example/generated/json/config_entity.g.dart';

/// 配置实体 - 测试复杂嵌套 Map
@JsonSerializable()
class ConfigEntity {
  late String version = '';
  
  /// 设置映射
  late Map<String, dynamic> settings = {};
  
  /// 元数据 - nullable Map
  Map<String, String>? metadata;
  
  /// 功能标志
  late Map<String, bool> featureFlags = {};
  
  ConfigEntity();
  
  factory ConfigEntity.fromJson(Map<String, dynamic> json) => $ConfigEntityFromJson(json);
  Map<String, dynamic> toJson() => $ConfigEntityToJson(this);
  
  @override
  String toString() {
    return jsonEncode(this);
  }
}
