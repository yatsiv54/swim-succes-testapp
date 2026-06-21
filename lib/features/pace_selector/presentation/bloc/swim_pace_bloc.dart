import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/pace_entity.dart';
import '../../domain/usecases/submit_pace_usecase.dart';
import 'swim_pace_event.dart';
import 'swim_pace_state.dart';

/// Manages the swim pace selection state including timer display,
/// slider synchronization, level calculation, and API submission.
class SwimPaceBloc extends Bloc<SwimPaceEvent, SwimPaceState> {
  final SubmitPaceUseCase _submitPaceUseCase;
  Timer? _debounceTimer;

  SwimPaceBloc({required SubmitPaceUseCase submitPaceUseCase})
      : _submitPaceUseCase = submitPaceUseCase,
        super(SwimPaceState.initial()) {
    on<IncrementMinutes>(_onIncrementMinutes);
    on<DecrementMinutes>(_onDecrementMinutes);
    on<IncrementSeconds>(_onIncrementSeconds);
    on<DecrementSeconds>(_onDecrementSeconds);
    on<UpdatePace>(_onUpdatePace);
    on<SubmitPace>(_onSubmitPace);
    on<SkipPaceSelection>(_onSkipPaceSelection);
    on<ResetPaceSelection>(_onResetPaceSelection);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  void _onIncrementMinutes(IncrementMinutes event, Emitter<SwimPaceState> emit) {
    _updatePace(state.minutes + 1, state.seconds, emit);
  }

  void _onDecrementMinutes(DecrementMinutes event, Emitter<SwimPaceState> emit) {
    _updatePace(state.minutes - 1, state.seconds, emit);
  }

  void _onIncrementSeconds(IncrementSeconds event, Emitter<SwimPaceState> emit) {
    int newSec = state.seconds + 1;
    int newMin = state.minutes;
    if (newSec >= 60) {
      newSec = 0;
      newMin += 1;
    }
    _updatePace(newMin, newSec, emit);
  }

  void _onDecrementSeconds(DecrementSeconds event, Emitter<SwimPaceState> emit) {
    int newSec = state.seconds - 1;
    int newMin = state.minutes;
    if (newSec < 0) {
      newSec = 59;
      newMin -= 1;
    }
    _updatePace(newMin, newSec, emit);
  }

  /// Instant handler for pace updates from slider drags and arrow buttons.
  /// UI updates immediately with no delay.
  void _onUpdatePace(UpdatePace event, Emitter<SwimPaceState> emit) {
    _updatePace(event.minutes, event.seconds, emit);
  }

  /// Debounced API submission (~500ms).
  /// If triggered rapidly (e.g. via slider changes), cancels previous
  /// pending requests and only fires after 500ms of inactivity.
  Future<void> _onSubmitPace(SubmitPace event, Emitter<SwimPaceState> emit) async {
    _debounceTimer?.cancel();

    final completer = Completer<void>();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      emit(state.copyWith(status: SwimPaceStatus.loading, errorMessage: null));
      try {
        await _submitPaceUseCase(state.totalSeconds);
        emit(state.copyWith(status: SwimPaceStatus.success));
      } catch (failure) {
        final String errorMsg = failure is Failure
            ? failure.message
            : 'An unexpected error occurred. Please try again.';
        emit(state.copyWith(
          status: SwimPaceStatus.failure,
          errorMessage: errorMsg,
        ));
      }
      completer.complete();
    });

    return completer.future;
  }

  void _onSkipPaceSelection(SkipPaceSelection event, Emitter<SwimPaceState> emit) {
    emit(state.copyWith(isSkipped: true));
  }

  void _onResetPaceSelection(ResetPaceSelection event, Emitter<SwimPaceState> emit) {
    emit(SwimPaceState.initial());
  }

  void _updatePace(int minutes, int seconds, Emitter<SwimPaceState> emit) {
    int total = minutes * 60 + seconds;

    // Clamp between 45 seconds (0:45) and 240 seconds (4:00)
    if (total < 45) total = 45;
    if (total > 240) total = 240;

    final newMin = total ~/ 60;
    final newSec = total % 60;
    final level = SwimmerLevel.fromSeconds(total);

    emit(SwimPaceState(
      minutes: newMin,
      seconds: newSec,
      level: level,
      status: SwimPaceStatus.initial,
      isSkipped: false,
    ));
  }
}
