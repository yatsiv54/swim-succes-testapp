import 'package:equatable/equatable.dart';

enum SwimmerLevel {
  elite('Elite'),
  advanced('Advanced'),
  intermediate('Intermediate'),
  beginner('Beginner');

  final String displayName;
  const SwimmerLevel(this.displayName);

  static SwimmerLevel fromSeconds(int totalSeconds) {
    if (totalSeconds < 70) return SwimmerLevel.elite; // < 1:10
    if (totalSeconds < 90) return SwimmerLevel.advanced; // 1:10 - 1:29
    if (totalSeconds < 120) return SwimmerLevel.intermediate; // 1:30 - 1:59
    return SwimmerLevel.beginner; // >= 2:00
  }
}

class PaceEntity extends Equatable {
  final int minutes;
  final int seconds;
  final SwimmerLevel level;

  const PaceEntity({
    required this.minutes,
    required this.seconds,
    required this.level,
  });

  int get totalSeconds => minutes * 60 + seconds;

  factory PaceEntity.fromSeconds(int totalSeconds) {
    final clamped = totalSeconds.clamp(45, 240);
    final min = clamped ~/ 60;
    final sec = clamped % 60;
    return PaceEntity(
      minutes: min,
      seconds: sec,
      level: SwimmerLevel.fromSeconds(clamped),
    );
  }

  @override
  List<Object?> get props => [minutes, seconds, level];
}
