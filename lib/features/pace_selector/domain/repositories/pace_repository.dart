abstract class PaceRepository {
  /// Submits the swimmer's fastest 100m freestyle pace in total seconds.
  /// Throws a [Failure] if the request fails.
  Future<void> submitPace(int paceSeconds);
}
