import 'package:crystallis/crystallis.dart';

@CrystallisData(mutable: true)
class $UserData {
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

  $UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
  });
}
