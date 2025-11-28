import 'package:example/generated/json/base/json_field.dart';
import 'dart:convert';

import 'package:example/generated/json/user_entity.g.dart';

/// 用户状态枚举
enum UserStatus {
  active,
  inactive,
  suspended,
  deleted,
}

/// 基础用户实体 - 测试基本类型字段
@JsonSerializable()
class UserEntity {
  /// 用户ID - late 非空字段
  late int id = 0;
  
  /// 用户名 - late 非空字符串
  late String username = '';
  
  /// 邮箱 - nullable 字段
  String? email;
  
  /// 年龄 - nullable int
  int? age;
  
  /// 是否激活
  late bool isActive = false;
  
  /// 评分 - double 类型
  late double rating = 0.0;
  
  /// 用户状态 - 枚举类型
  @JSONField(isEnum: true)
  UserStatus? status;
  
  UserEntity();
  
  factory UserEntity.fromJson(Map<String, dynamic> json) => $UserEntityFromJson(json);
  Map<String, dynamic> toJson() => $UserEntityToJson(this);
  
  @override
  String toString() {
    return jsonEncode(this);
  }
}
