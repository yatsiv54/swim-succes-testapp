import 'package:equatable/equatable.dart';

abstract class SwimPaceEvent extends Equatable {
  const SwimPaceEvent();

  @override
  List<Object?> get props => [];
}

class IncrementMinutes extends SwimPaceEvent {}

class DecrementMinutes extends SwimPaceEvent {}

class IncrementSeconds extends SwimPaceEvent {}

class DecrementSeconds extends SwimPaceEvent {}

class UpdatePace extends SwimPaceEvent {
  final int minutes;
  final int seconds;

  const UpdatePace({required this.minutes, required this.seconds});

  @override
  List<Object?> get props => [minutes, seconds];
}

class SubmitPace extends SwimPaceEvent {}

class SkipPaceSelection extends SwimPaceEvent {}

class ResetPaceSelection extends SwimPaceEvent {}
