import 'package:flutter/foundation.dart';

enum WorkoutPhase {
  prep,
  work,
  rest,
  finished,
}

@immutable
class WorkoutConfig {
  final int sets;
  final int reps;
  final int repDuration; // seconds per rep
  final int restTime; // seconds rest interval
  final int prepTime; // seconds countdown

  const WorkoutConfig({
    this.sets = 3,
    this.reps = 10,
    this.repDuration = 4,
    this.restTime = 90,
    this.prepTime = 3,
  });

  WorkoutConfig copyWith({
    int? sets,
    int? reps,
    int? repDuration,
    int? restTime,
    int? prepTime,
  }) {
    return WorkoutConfig(
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      repDuration: repDuration ?? this.repDuration,
      restTime: restTime ?? this.restTime,
      prepTime: prepTime ?? this.prepTime,
    );
  }
}

@immutable
class WorkoutState {
  final bool isRunning;
  final bool isPaused;
  final WorkoutPhase phase;
  final int currentSet;
  final int currentRep;
  final double phaseElapsedSeconds;
  final double totalElapsedSeconds;

  const WorkoutState({
    this.isRunning = false,
    this.isPaused = false,
    this.phase = WorkoutPhase.prep,
    this.currentSet = 1,
    this.currentRep = 0,
    this.phaseElapsedSeconds = 0.0,
    this.totalElapsedSeconds = 0.0,
  });

  WorkoutState copyWith({
    bool? isRunning,
    bool? isPaused,
    WorkoutPhase? phase,
    int? currentSet,
    int? currentRep,
    double? phaseElapsedSeconds,
    double? totalElapsedSeconds,
  }) {
    return WorkoutState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      phase: phase ?? this.phase,
      currentSet: currentSet ?? this.currentSet,
      currentRep: currentRep ?? this.currentRep,
      phaseElapsedSeconds: phaseElapsedSeconds ?? this.phaseElapsedSeconds,
      totalElapsedSeconds: totalElapsedSeconds ?? this.totalElapsedSeconds,
    );
  }
}
