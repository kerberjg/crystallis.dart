# crystallis.dart
💠✨ Data class codegen w/ validation &amp; runtime metadata for Dart

## Features

- per-field validation via annotations
- generated runtime metadata
- validated setters
- full-object validation
- optional (im)mutability

It's designed to be practical, easy to extend, and applicable in a variety of use cases, such as:
- serialization
- form builders
- etc

---

## Installation

Add `crystallis` to your `pubspec.yaml`:

```yaml
dependencies:
  crystallis: ^0.0.1

dev_dependencies:
  build_runner: ^2.4.0
```

## Usage

After installing, run codegen with:

```bash
dart run build_runner build
```
