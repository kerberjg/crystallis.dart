# crystallis_generator

Code generator for [`crystallis`](../crystallis). Generates data classes, validation hooks, and runtime metadata via `build_runner`.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
    crystallis: ^0.0.1

dev_dependencies:
    crystallis_generator: ^0.0.1
    build_runner: ^2.4.0
```

## Usage

Run code generation:

```bash
dart run build_runner build
```

Watch for changes:

```bash
dart run build_runner watch
```