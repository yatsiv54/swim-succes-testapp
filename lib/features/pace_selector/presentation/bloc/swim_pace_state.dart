import 'package:equatable/equatable.dart';
import '../../domain/entities/pace_entity.dart';

enum SwimPaceStatus { initial, loading, success, failure }

class SwimPaceState extends Equatable {
  final int minutes;
  final int seconds;
  final SwimmerLevel level;
  final SwimPaceStatus status;
  final String? errorMessage;
  final bool isSkipped;

  const SwimPaceState({
    required this.minutes,
    required this.seconds,
    required this.level,
    this.status = SwimPaceStatus.initial,
    this.errorMessage,
    this.isSkipped = false,
  });

  int get totalSeconds => minutes * 60 + seconds;

  factory SwimPaceState.initial() {
    return const SwimPaceState(
      minutes: 1,
      seconds: 43,
      level: SwimmerLevel.intermediate,
      status: SwimPaceStatus.initial,
      isSkipped: false,
    );
  }

  SwimPaceState copyWith({
    int? minutes,
    int? seconds,
    SwimmerLevel? level,
    SwimPaceStatus? status,
    String? errorMessage,
    bool? isSkipped,
  }) {
    return SwimPaceState(
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      level: level ?? this.level,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isSkipped: isSkipped ?? this.isSkipped,
    );
  }

  @override
  List<Object?> get props => [minutes, seconds, level, status, errorMessage, isSkipped];
}
