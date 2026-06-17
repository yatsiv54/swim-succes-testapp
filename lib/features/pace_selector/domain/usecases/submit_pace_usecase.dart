import '../repositories/pace_repository.dart';

class SubmitPaceUseCase {
  final PaceRepository _repository;

  SubmitPaceUseCase(this._repository);

  Future<void> call(int paceSeconds) async {
    return await _repository.submitPace(paceSeconds);
  }
}
