import 'package:example/generated/json/base/json_field.dart';
import 'package:example/generated/json/employee_entity.g.dart';
import 'package:example/models/address_entity.dart';
import 'dart:convert';

/// 部门类型枚举
enum DepartmentType {
  engineering,
  sales,
  marketing,
  hr,
}

/// 员工实体 - 测试嵌套对象和自定义 JSON 键
@JsonSerializable()
class EmployeeEntity {
  /// 员工ID
  late int id = 0;
  
  /// 员工姓名 - 使用自定义 JSON 键
  @JSONField(name: 'full_name')
  late String name = '';
  
  /// 公司邮箱
  @JSONField(name: 'company_email')
  String? email;
  
  /// 部门 - 枚举字段
  @JSONField(isEnum: true)
  DepartmentType? department;
  
  /// 家庭地址 - 嵌套对象
  AddressEntity? homeAddress;
  
  /// 办公室地址 - 嵌套对象
  AddressEntity? officeAddress;
  
  /// 薪水 - 不参与序列化
  @JSONField(serialize: false)
  double? salary;
  
  /// 内部备注 - 不参与反序列化
  @JSONField(deserialize: false)
  String? internalNotes;
  
  EmployeeEntity();
  
  factory EmployeeEntity.fromJson(Map<String, dynamic> json) => $EmployeeEntityFromJson(json);
  Map<String, dynamic> toJson() => $EmployeeEntityToJson(this);
  
  @override
  String toString() {
    return jsonEncode(this);
  }
}
