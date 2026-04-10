import 'package:crystallis/crystallis.dart';

@Crystallise(mutable: true, useDeepEquality: true, useDeepCopy: true)
class User {
  @Range(min: 1)
  final int id;

  @NotEmpty()
  @LengthRange(min: 2, max: 50)
  String name;

  String? nickname;

  @Email()
  String email;

  @Alphanumeric()
  @LengthRange(min: 3, max: 20)
  String username;

  @AllowedValues({'admin', 'user', 'guest'})
  String role;

  List<String> favoriteFoods;

  Map<int, String> associations;

  User({
    required this.id,
    required this.name,
    this.nickname,
    required this.email,
    required this.username,
    required this.role,
    required this.favoriteFoods,
    required this.associations,
  });
}
