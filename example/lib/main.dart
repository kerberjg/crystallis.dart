import 'package:crystallis/crystallis.dart';
import 'user_data.data.g.dart';

void main() {
  // Construct a valid instance
  final user = UserData(
    id: 1,
    name: 'Alice',
    email: 'alice@example.com',
    username: 'alice123',
    role: 'user',
  );

  // Metadata usage
  print('Fields: ${user.metadata.keys.toList()}');
  print('email type: ${user.metadata['email']?.type}');
  print(
      'name validators: ${user.metadata['name']?.validators.map((v) => v.runtimeType).toList()}');

  // Validate all fields (includes fields with zero validators as empty lists)
  final all1 = user.validate();
  print('Initial validation:');
  all1.forEach((k, v) => print('  $k: ${v.length} error(s)'));

  // Successful set()
  user.set('name', 'Bob');
  print('Updated name: ${user.get('name')}');

  // set() with multiple validators failing (collects all, throws List<ValidationException>)
  try {
    user.set('name', ''); // NotEmpty + LengthRange will fail
  } catch (e) {
    if (e is List<ValidationException>) {
      print('Setting name failed with ${e.length} validation error(s):');
      for (final err in e) {
        print('  - validator=${err.validator.runtimeType}, value=${err.value}');
      }
    } else {
      rethrow;
    }
  }

  // set() with type mismatch (throws ArgumentError)
  try {
    user.set('id', 'not a number');
  } catch (e) {
    print('Setting id failed: $e');
  }

  // Full validation after attempted changes
  final all2 = user.validate();
  print('Final validation:');
  all2.forEach((k, v) => print('  $k: ${v.length} error(s)'));
}
