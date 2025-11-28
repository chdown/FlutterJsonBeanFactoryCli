# Example 项目 - 测试实体说明

本目录包含用于测试 FlutterJsonBeanFactory CLI 插件的示例 Flutter 项目。

## 测试实体列表

### 1. `user_entity.dart` - 基础类型测试
测试内容：
- ✅ `late` 非空字段（int, String, bool, double）
- ✅ nullable 字段（String?, int?）
- ✅ 枚举类型（UserStatus）
- ✅ `@JSONField(isEnum: true)` 注解

### 2. `address_entity.dart` - 简单嵌套对象
测试内容：
- ✅ 基本字符串字段
- ✅ nullable 字段
- ✅ 作为其他实体的嵌套对象使用

### 3. `employee_entity.dart` - 复杂注解测试
测试内容：
- ✅ `@JSONField(name: 'xxx')` - 自定义 JSON 键
- ✅ `@JSONField(serialize: false)` - 不参与序列化
- ✅ `@JSONField(deserialize: false)` - 不参与反序列化
- ✅ `@JSONField(isEnum: true)` - 枚举字段
- ✅ 多个嵌套对象（homeAddress, officeAddress）

### 4. `post_entity.dart` - List 类型测试
测试内容：
- ✅ 基本类型 List（`List<String>`, `List<int>`）
- ✅ 对象类型 List（`List<UserEntity>`）
- ✅ nullable List（`List<String>?`）
- ✅ 嵌套对象字段

### 5. `product_entity.dart` - 枚举 List 和 Map 测试
测试内容：
- ✅ 枚举 List（`List<Color>`）
- ✅ nullable 枚举 List（`List<Color>?`）
- ✅ Map 类型（`Map<String, dynamic>`）
- ✅ `@JSONField(isEnum: true)` 应用于 List

### 6. `empty_entity.dart` - 边界情况测试
测试内容：
- ✅ 空类（没有任何字段）
- ✅ 验证空 extension 生成

### 7. `config_entity.dart` - 复杂 Map 测试
测试内容：
- ✅ 不同类型的 Map（`Map<String, dynamic>`, `Map<String, String>`, `Map<String, bool>`）
- ✅ nullable Map

## 如何使用

### 1. 安装依赖
```bash
cd example
flutter pub get
```

### 2. 运行代码生成
从项目根目录运行：
```bash
dart run flutter_json_bean_factory --project example
```

或从 example 目录内运行：
```bash
dart run flutter_json_bean_factory
```

### 3. 查看生成的文件
生成的文件将位于：
- `lib/generated/json/base/json_field.dart` - 注解定义
- `lib/generated/json/base/json_convert_content.dart` - 转换工具
- `lib/generated/json/*.g.dart` - 各实体的序列化代码

### 4. 测试场景

#### 基本序列化/反序列化
```dart
import 'package:example/models/user_entity.dart';

// 反序列化
final json = {
  'id': 1,
  'username': 'john_doe',
  'email': 'john@example.com',
  'age': 30,
  'isActive': true,
  'rating': 4.5,
  'status': 'active',
};
final user = UserEntity.fromJson(json);

// 序列化
final jsonOutput = user.toJson();
print(user); // 使用 toString() 输出 JSON
```

#### 测试自定义 JSON 键
```dart
import 'package:example/models/employee_entity.dart';

final json = {
  'id': 1,
  'full_name': 'Jane Smith',  // 注意：JSON 中使用 full_name
  'company_email': 'jane@company.com',
  'department': 'engineering',
};
final employee = EmployeeEntity.fromJson(json);
print(employee.name); // 输出: Jane Smith
```

#### 测试 List 和嵌套对象
```dart
import 'package:example/models/post_entity.dart';

final json = {
  'id': 1,
  'title': 'Test Post',
  'content': 'Content here',
  'tags': ['flutter', 'dart'],
  'viewCounts': [100, 200, 300],
  'author': {
    'id': 1,
    'username': 'author',
    'email': 'author@example.com',
  },
  'relatedUsers': [
    {'id': 2, 'username': 'user2'},
    {'id': 3, 'username': 'user3'},
  ],
};
final post = PostEntity.fromJson(json);
```

#### 测试枚举 List
```dart
import 'package:example/models/product_entity.dart';

final json = {
  'id': 1,
  'name': 'T-Shirt',
  'price': 29.99,
  'availableColors': ['red', 'blue', 'green'],
  'recommendedColors': ['blue'],
};
final product = ProductEntity.fromJson(json);
```

## 预期结果

运行代码生成后，应该生成以下文件：
- ✅ `address_entity.g.dart`
- ✅ `config_entity.g.dart`
- ✅ `employee_entity.g.dart`
- ✅ `empty_entity.g.dart`
- ✅ `post_entity.g.dart`
- ✅ `product_entity.g.dart`
- ✅ `user_entity.g.dart`

每个 `.g.dart` 文件应包含：
- `$XxxEntityFromJson` 函数
- `$XxxEntityToJson` 函数
- `XxxEntityExtension` 扩展（包含 copyWith 方法）

## 验证要点

1. ✅ 所有实体都能正确序列化和反序列化
2. ✅ nullable 字段正确处理 null 值
3. ✅ 枚举字段使用 `values.byName()` 正确转换
4. ✅ 自定义 JSON 键正确映射
5. ✅ serialize/deserialize 标记正确工作
6. ✅ List 和 Map 类型正确处理
7. ✅ 空类生成空的 extension
8. ✅ 嵌套对象的 import 自动添加
