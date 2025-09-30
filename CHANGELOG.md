# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-21

### Added
- Initial release of FlutterJsonBeanFactory CLI
- Cross-platform support for Windows, macOS, and Linux
- AI-driven code generation using `package:analyzer` for precise AST parsing
- Support for `@JsonSerializable()` and `@JSONField()` annotations
- Automatic generation of:
  - `json_field.dart` - JSON field annotation definitions
  - `json_convert_content.dart` - JSON conversion utilities
  - `*.g.dart` files - Entity serialization helpers with `copyWith` extensions
- Configuration via `pubspec.yaml` and command-line arguments
- Automatic import resolution for nested entities and Flutter UI types
- Smart cleanup of outdated generated files
- Comprehensive logging with configurable levels
- CI/CD integration examples for GitHub Actions and Jenkins

### Features
- **Precise Output Matching**: Generated code exactly matches the original FlutterJsonBeanFactory plugin output
- **Empty Class Support**: Proper handling of empty classes with `@JsonSerializable()` annotation
- **Generic Type Support**: Full support for `List<T>`, nested models, and complex data structures
- **Field-level Annotations**: Support for `@JSONField()` with custom JSON keys and serialization control
- **Automatic Dependency Resolution**: Smart detection and addition of necessary imports
- **Model Suffix Configuration**: Configurable suffix for generated model files

### Technical Details
- Built with Dart 3.0+ and Flutter 3.0+ support
- Uses `package:analyzer` for accurate code analysis
- Leverages AI technology for pattern recognition and code generation
- Compatible with existing FlutterJsonBeanFactory projects
- Zero breaking changes from original plugin behavior

### Acknowledgments
- Based on the original [FlutterJsonBeanFactory](https://github.com/fluttercandies/FlutterJsonBeanFactory) plugin
- Special thanks to [@fluttercandies](https://github.com/fluttercandies) for the excellent original work
- AI-driven development approach for precise feature replication
