import 'package:example/generated/json/base/json_field.dart';
import 'dart:convert';

import 'package:example/generated/json/empty_entity.g.dart';

/// 空实体 - 测试边界情况
@JsonSerializable()
class EmptyEntity {
  EmptyEntity();
  
  factory EmptyEntity.fromJson(Map<String, dynamic> json) => $EmptyEntityFromJson(json);
  Map<String, dynamic> toJson() => $EmptyEntityToJson(this);
  
  @override
  String toString() {
    return jsonEncode(this);
  }
}
