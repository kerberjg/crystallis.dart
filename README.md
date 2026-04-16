<div align="center">

# crystallis.dart
💠✨ Data class codegen w/ validation &amp; runtime metadata for Dart

```bash
dart pub get crystallis
```

_also see [`crystallis_codegen`](https://github.com/kerberjg/crystallis_generator) ([pub.dev](https://pub.dev/packages/crystallis_generator))_

<!-- Badges -->
<!-- remember to update these badges when using the template! -->

[![License: MPL 2.0](https://img.shields.io/badge/License-MPL_2.0-brightgreen.svg)](LICENSE)
[![build](https://github.com/kerberjg/crystallis.dart/actions/workflows/package.yaml/badge.svg)](https://github.com/kerberjg/crystallis.dart/actions/workflows/package.yaml)
[![example](https://github.com/kerberjg/crystallis.dart/actions/workflows/example.yaml/badge.svg)](https://github.com/kerberjg/crystallis.dart/actions/workflows/example.yaml)
[![stars](https://img.shields.io/github/stars/kerberjg/crystallis.dart.svg)](https://github.com/kerberjg/crystallis.dart/stargazers)
<br/>
[![pub package](https://img.shields.io/pub/v/crystallis?logo=dart)](https://pub.dev/packages/crystallis)
[![pub score](https://img.shields.io/pub/points/crystallis?logo=dart)](https://pub.dev/packages/crystallis/score)
[![likes](https://img.shields.io/pub/likes/crystallis?logo=dart)](https://pub.dev/packages/crystallis/score)

</div>

### 💙 Use cases
- **Data classes** with generated copy/get/set methods
- **Validation** of fields and entire objects at runtime
- **Runtime metadata** for reflection, serialization, form building, etc


## ✨ Features
- Codegen-based data classes (`copyWith`, constructors, get/set, equality, etc)
- Supports both mutable and immutable classes!
- Per-field validation via annotations (`@Min(1)`, `@Max(100)`, `@Regex('^[a-z]+\$')`, etc)
- JSON-compatible de/serialization
  - Per-field customizable serializers via `@Serializer(...)` annotation
  - `serialize` method returning `Map<String, dynamic>`
  - Generates a `deserialize` constructor
- Runtime reflection (field metadata available for all annotated classes)
- `setFrom`: copy compatible fields between different data classes
- Optional per-class deep copying/equality for collections
- Full-object validation
- String-named getter/setter methods
- Optimized for runtime performance and minimal overhead

#### Coming up next:
- Support for native/FFI types
- `ByteBuffer` serialization/deserialization
- More validators

---

## 🔮 Usage Guide

### Getting Started

1. Add the following to your `pubspec.yaml`:
```dart
dependencies:
  crystallis: ^<latest_version>

dev_dependencies:
  crystallis_generator: ^<latest_version>
  build_runner: ^2.13.1
```

...or run the following to ensure the latest version:

```bash
dart pub add crystallis dev:crystallis_generator dev:build_runner
```

2. Annotate your data classes with `@Crystallise()` and define fields with validation annotations as needed.
  - TODO: Add example here

3. Run the code generator:
```bash
dart run build_runner build
```
 - Alternatively: use `watch` for continuous code generation during development:
```bash
dart run build_runner watch
```

4. Use the generated classes in your application!
### Example

```dart
/// TODO
```

### Development & Maintenance

TODO

---

## 📄 License

This project is licensed under the Mozilla Public License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🔥 Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes. Make sure to read the following guidelines before contributing:

- [Code of Conduct](CODE_OF_CONDUCT.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- ["Effective Dart" Style Guide](https://dart.dev/guides/language/effective-dart)
- [**pub.dev** Package Publishing Guidelines](https://dart.dev/tools/pub/publishing)

## 🙏 Credits & Acknowledgements

<!-- REMEMBER! Update the URLs below to point to your own username/repo! -->

### Contributors 🧑‍💻💙📝

This package is developed/maintained by the following rockstars!
Your contributions make a difference! 💖

![contributors badge](https://readme-contribs.as93.net/contributors/kerberjg/crystallis.dart?textColor=888888)

### Sponsors 🫶✨🥳

Kind thanks to all our sponsors! Thank you for supporting the Dart/Flutter community, and keeping open source alive! 💙

![sponsors badge](https://readme-contribs.as93.net/sponsors/kerberjg?textColor=888888)

---

> Based on [`dart_package_template`](https://github.com/kerberjg/dart_package_template) - a high-quality Dart package template with best practices, CI/CD, and more! 💙✨