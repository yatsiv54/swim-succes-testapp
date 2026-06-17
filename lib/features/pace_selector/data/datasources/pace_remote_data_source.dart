import '../../../../core/network/api_client.dart';

abstract class PaceRemoteDataSource {
  Future<void> submitPace(int paceSeconds);
}

class PaceRemoteDataSourceImpl implements PaceRemoteDataSource {
  final ApiClient _apiClient;

  PaceRemoteDataSourceImpl(this._apiClient);

  @override
  Future<void> submitPace(int paceSeconds) async {
    const String endpoint = 'https://jsonplaceholder.typicode.com/posts';
    final Map<String, dynamic> body = {
      'pace_seconds': paceSeconds,
    };
    
    // Perform post request, handling response formatting
    await _apiClient.post(endpoint, body);
  }
}
