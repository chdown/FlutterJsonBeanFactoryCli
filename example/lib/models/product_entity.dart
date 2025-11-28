import 'package:example/generated/json/base/json_field.dart';
import 'dart:convert';

import 'package:example/generated/json/product_entity.g.dart';

/// 颜色枚举
enum Color {
  red,
  green,
  blue,
  yellow,
}

/// 产品实体 - 测试枚举列表
@JsonSerializable()
class ProductEntity {
  late int id = 0;
  late String name = '';
  late double price = 0.0;
  
  /// 可用颜色 - 枚举列表
  @JSONField(isEnum: true)
  late List<Color> availableColors = [];
  
  /// 推荐颜色 - nullable 枚举列表
  @JSONField(isEnum: true)
  List<Color>? recommendedColors;
  
  /// 属性映射
  late Map<String, dynamic> attributes = {};
  
  ProductEntity();
  
  factory ProductEntity.fromJson(Map<String, dynamic> json) => $ProductEntityFromJson(json);
  Map<String, dynamic> toJson() => $ProductEntityToJson(this);
  
  @override
  String toString() {
    return jsonEncode(this);
  }
}
