import '../entities/user_entity.dart';

abstract class UserRepository {
  /// Fetches the list of users from JSONPlaceholder.
  /// Throws a [Failure] on failure or connection issues.
  Future<List<UserEntity>> getUsers();
}
