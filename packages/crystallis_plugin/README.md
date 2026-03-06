# crystallis_plugin

This plugin provides additional verifications for the Crystallis code generator. It checks for the presence of the annotations and ensures that they are used correctly.

## Installation

Add to your `analysis_options.yaml`:

```yaml
plugins:
  crystallis_plugin:
    version: ^0.0.4
```

Now when you open your prefered IDE or run `dart analyze`, you will see warnings if you are using the annotations incorrectly.
