import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  /// Calls the GET https://jsonplaceholder.typicode.com/users endpoint.
  /// Throws a [ServerException] or [NetworkException] if anything goes wrong.
  Future<List<UserModel>> getUsers();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient _apiClient;

  UserRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<UserModel>> getUsers() async {
    const String url = 'https://jsonplaceholder.typicode.com/users';
    final response = await _apiClient.get(url);

    if (response is List) {
      return response
          .map((userJson) => UserModel.fromJson(userJson as Map<String, dynamic>))
          .toList();
    } else {
      throw ServerException('Invalid server response format');
    }
  }
}
