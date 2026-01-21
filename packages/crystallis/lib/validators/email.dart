import 'package:crystallis/validators/regex.dart';

// ignore: public_member_api_docs
class Email extends RegEx {
  /// [Validator] that checks if a String value is a valid email address.
  const Email() : super(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
}
