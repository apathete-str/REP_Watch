import 'package:flutter/foundation.dart';

enum WorkoutPhase {
  prep,
  work,
  repRest,
  rest,
  finished,
}

@immutable
class WorkoutConfig {
  final int sets;
  final int reps;
  final int repDuration; // seconds per rep
  final int repRestTime; // seconds rest between each rep (e.g. cluster/pause reps)
  final int restTime; // seconds rest interval between sets
  final int prepTime; // seconds countdown before workout
  final bool vibrateOnSetStart;
  final bool vibrateOnSetComplete;

  const WorkoutConfig({
    this.sets = 3,
    this.reps = 10,
    this.repDuration = 4,
    this.repRestTime = 0,
    this.restTime = 90,
    this.prepTime = 3,
    this.vibrateOnSetStart = true,
    this.vibrateOnSetComplete = true,
  });

  WorkoutConfig copyWith({
    int? sets,
    int? reps,
    int? repDuration,
    int? repRestTime,
    int? restTime,
    int? prepTime,
    bool? vibrateOnSetStart,
    bool? vibrateOnSetComplete,
  }) {
    return WorkoutConfig(
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      repDuration: repDuration ?? this.repDuration,
      repRestTime: repRestTime ?? this.repRestTime,
      restTime: restTime ?? this.restTime,
      prepTime: prepTime ?? this.prepTime,
      vibrateOnSetStart: vibrateOnSetStart ?? this.vibrateOnSetStart,
      vibrateOnSetComplete: vibrateOnSetComplete ?? this.vibrateOnSetComplete,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutConfig &&
          runtimeType == other.runtimeType &&
          sets == other.sets &&
          reps == other.reps &&
          repDuration == other.repDuration &&
          repRestTime == other.repRestTime &&
          restTime == other.restTime &&
          prepTime == other.prepTime &&
          vibrateOnSetStart == other.vibrateOnSetStart &&
          vibrateOnSetComplete == other.vibrateOnSetComplete;

  @override
  int get hashCode => Object.hash(
        sets,
        reps,
        repDuration,
        repRestTime,
        restTime,
        prepTime,
        vibrateOnSetStart,
        vibrateOnSetComplete,
      );
}

@immutable
class WorkoutPreset {
  final String id;
  final String name;
  final String? description;
  final WorkoutConfig config;
  final bool isDefault;

  const WorkoutPreset({
    required this.id,
    required this.name,
    this.description,
    required this.config,
    this.isDefault = false,
  });

  String get summary {
    final buffer = StringBuffer('${config.sets}x${config.reps} • ${config.repDuration}s');
    if (config.repRestTime > 0) {
      buffer.write(' (+${config.repRestTime}s rep-rest)');
    }
    buffer.write(' • ${config.restTime}s rest');
    return buffer.toString();
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
