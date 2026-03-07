# crystallis_plugin

This plugin provides additional verifications for the Crystallis code generator. It checks for the presence of the annotations and ensures that they are used correctly.

## Installation

Add to your `analysis_options.yaml`:

```yaml
include: package:crystallis_plugin/rules.yaml
```

or, if you have multiple includes:

```yaml
include:
  - package:lints/recommended.yaml
  - package:crystallis_plugin/rules.yaml
```

Now when you open your prefered IDE or run `dart analyze`, you will see warnings if you are using the annotations incorrectly.
