import 'package:crystallis/validators/regex.dart';

class Email extends RegEx {
  const Email() : super(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
}
