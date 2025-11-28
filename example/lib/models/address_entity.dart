import 'package:example/generated/json/address_entity.g.dart';
import 'package:example/generated/json/base/json_field.dart';
import 'dart:convert';

/// 地址实体 - 嵌套对象测试
@JsonSerializable()
class AddressEntity {
  late String street = '';
  late String city = '';
  late String country = '';
  String? zipCode;
  
  AddressEntity();
  
  factory AddressEntity.fromJson(Map<String, dynamic> json) => $AddressEntityFromJson(json);
  Map<String, dynamic> toJson() => $AddressEntityToJson(this);
  
  @override
  String toString() {
    return jsonEncode(this);
  }
}
