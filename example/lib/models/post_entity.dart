import 'package:example/generated/json/base/json_field.dart';
import 'package:example/generated/json/post_entity.g.dart';
import 'package:example/models/user_entity.dart';
import 'dart:convert';

/// 博客文章实体 - 测试 List 类型
@JsonSerializable()
class PostEntity {
  late int id = 0;
  late String title = '';
  late String content = '';
  
  /// 作者信息 - 嵌套对象
  UserEntity? author;
  
  /// 标签列表 - 基本类型 List
  late List<String> tags = [];
  
  /// 评论数列表 - 数字 List
  late List<int> viewCounts = [];
  
  /// 相关用户列表 - 对象 List
  late List<UserEntity> relatedUsers = [];
  
  /// 可选的分类列表
  List<String>? categories;
  
  PostEntity();
  
  factory PostEntity.fromJson(Map<String, dynamic> json) => $PostEntityFromJson(json);
  Map<String, dynamic> toJson() => $PostEntityToJson(this);
  
  @override
  String toString() {
    return jsonEncode(this);
  }
}
