import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/pace_repository.dart';
import '../datasources/pace_remote_data_source.dart';

class PaceRepositoryImpl implements PaceRepository {
  final PaceRemoteDataSource _remoteDataSource;

  PaceRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> submitPace(int paceSeconds) async {
    try {
      await _remoteDataSource.submitPace(paceSeconds);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }
}
