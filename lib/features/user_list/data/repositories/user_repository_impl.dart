import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<UserEntity>> getUsers() async {
    try {
      final userModels = await _remoteDataSource.getUsers();
      return userModels;
    } on NetworkException {
      throw const NetworkFailure('No internet connection. Please check your network and try again.');
    } on ServerException catch (e) {
      if (e.message.contains('404')) {
        throw const ServerFailure('Requested resource not found. Please try again later.');
      }
      throw const ServerFailure('Server error. Please try again later.');
    } catch (e) {
      throw const ServerFailure('Something went wrong. Please try again.');
    }
  }
}
