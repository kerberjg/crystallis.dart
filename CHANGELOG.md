# 0.0.4

- **🛑 Breaking**: Renamed `@CrystallisData` to `@Crystallise`, and `CrystallisMixin` to `CrystallisData`
- Introduced `MutableCrystallisData` and `ImmutableCrystallisData` for better code path splitting
- **🛑 Breaking**: Renamed `copyFrom` to `setFrom` to better reflect its purpose
- **🛑 Breaking**: Implemented a (new) `copyFrom`: it creates a new instance (like `copyWith`) by copying compatible fields from another instance (like `setFrom`)
- **✨ New!**  `copyWith` now supports explicit/implicit null distinction, allowing nullable fields to be set to null via `copyWith` without ambiguity (#6, #7, thanks @FMorschel 🩵!)
- **✨ New!**  Implemented `tryGet`: a safe alternative to `get` that returns `null` instead of throwing if the field doesn't exist or is of an incompatible type
- **🔧 Fixed** support for multiple data classes per file (#5)
- Improved annotation constraints and error messages for a better developer experience
- Fixed nullable fields not being supported (#2)
- Refactored serialization
    - Fixed JSON incompatibility with some non-String keys
    - Improved testing
    - Improved map deserialization (maintains original key/value types instead of (now broken) heuristics)
    - **🛑 Breaking**: Renamed `@Serializer` to `@Serializable` and added a `Serializer` base abstract class class for better extensibility
    - Properly implemented codegen for custom serializers via field annotations


# 0.0.3

- Implemented serialization!
    - Per-field `@Serializer` annotation to customize de/serialization
    - Built-in support for primitive types, lists, maps, and nested Crystallis data classes
    - `serialize` method to convert to JSON-compatible `Map<String, dynamic>`
    - Generates a `deserialize` constructor to create instances from `Map<String, dynamic>` (optional, on by default)
- Added `copyFrom` method to copy compatible fields between different data classes

# 0.0.2

- Implemented generation for `toString`, `==`, and `hashCode` methods (optional, on by default)
- Added `useDeepEquality` option to control deep equality checks for collections (off by default)
- Made `copyWith` method generation optional (on by default)
- Added `useDeepCopy` option to control deep copying of collections in `copyWith` (off by default)
- Added export for `@immutable` from `package:meta`

# 0.0.1

Initial release.