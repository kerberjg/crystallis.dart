import 'package:crystallis/crystallis.dart';

@CrystallisData(mutable: true, useDeepEquality: true, useDeepCopy: true)
class User {
  @Range(min: 1)
  int id;

  @NotEmpty()
  @LengthRange(min: 2, max: 50)
  String name;

  @Email()
  String email;

  @Alphanumeric()
  @LengthRange(min: 3, max: 20)
  String username;

  @AllowedValues({'admin', 'user', 'guest'})
  String role;

  List<String> favoriteFoods;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    required this.favoriteFoods,
  });
}
