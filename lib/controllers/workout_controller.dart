import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/workout_model.dart';

class WorkoutController extends ChangeNotifier {
  WorkoutConfig _config = const WorkoutConfig();
  WorkoutState _state = const WorkoutState();

  WorkoutConfig get config => _config;
  WorkoutState get state => _state;

  Timer? _timer;
  int _lastTickRep = -1;

  // Preset Configurations
  void updateSets(int delta) {
    final newSets = (_config.sets + delta).clamp(1, 50);
    _config = _config.copyWith(sets: newSets);
    notifyListeners();
  }

  void updateReps(int delta) {
    final newReps = (_config.reps + delta).clamp(1, 100);
    _config = _config.copyWith(reps: newReps);
    notifyListeners();
  }

  void updateRepDuration(int delta) {
    final newDuration = (_config.repDuration + delta).clamp(1, 30);
    _config = _config.copyWith(repDuration: newDuration);
    notifyListeners();
  }

  void updateRepRestTime(int delta) {
    final newRepRest = (_config.repRestTime + delta).clamp(0, 30);
    _config = _config.copyWith(repRestTime: newRepRest);
    notifyListeners();
  }

  void toggleVibrateOnSetStart() {
    _config = _config.copyWith(vibrateOnSetStart: !_config.vibrateOnSetStart);
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void toggleVibrateOnSetComplete() {
    _config = _config.copyWith(vibrateOnSetComplete: !_config.vibrateOnSetComplete);
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void updateRestTime(int delta) {
    final newRest = (_config.restTime + delta).clamp(5, 600);
    _config = _config.copyWith(restTime: newRest);
    notifyListeners();
  }

  static final List<WorkoutPreset> defaultPresets = [
    const WorkoutPreset(
      id: 'hypertrophy',
      name: 'Hypertrophy',
      description: 'Classic muscle growth cadence',
      isDefault: true,
      config: WorkoutConfig(sets: 3, reps: 10, repDuration: 4, restTime: 90),
    ),
    const WorkoutPreset(
      id: 'strength',
      name: 'Heavy Strength',
      description: 'Slow eccentric & heavier load',
      isDefault: true,
      config: WorkoutConfig(sets: 5, reps: 5, repDuration: 5, restTime: 120),
    ),
    const WorkoutPreset(
      id: 'endurance',
      name: 'Endurance',
      description: 'High rep volume with short rest',
      isDefault: true,
      config: WorkoutConfig(sets: 4, reps: 15, repDuration: 3, restTime: 60),
    ),
    const WorkoutPreset(
      id: 'speed_power',
      name: 'Power & Speed',
      description: 'Fast explosive contractions',
      isDefault: true,
      config: WorkoutConfig(sets: 4, reps: 6, repDuration: 2, restTime: 75),
    ),
    const WorkoutPreset(
      id: 'tabata_tempo',
      name: 'High Density',
      description: 'Short paced rest intervals',
      isDefault: true,
      config: WorkoutConfig(sets: 6, reps: 8, repDuration: 3, restTime: 45),
    ),
  ];

  late final List<WorkoutPreset> _presets = List.from(defaultPresets);

  List<WorkoutPreset> get presets => List.unmodifiable(_presets);

  void addCustomPreset({
    required String name,
    required WorkoutConfig config,
  }) {
    final newPreset = WorkoutPreset(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Custom Preset' : name.trim(),
      config: config,
      isDefault: false,
    );
    _presets.add(newPreset);
    _config = config;
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void removePreset(String id) {
    _presets.removeWhere((p) => p.id == id && !p.isDefault);
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void applyPresetConfig(WorkoutConfig presetConfig) {
    _config = presetConfig;
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void applyPreset({
    required int sets,
    required int reps,
    required int duration,
    required int rest,
  }) {
    _config = WorkoutConfig(
      sets: sets,
      reps: reps,
      repDuration: duration,
      restTime: rest,
    );
    notifyListeners();
  }

  // Workout Controls
  void startWorkout() {
    _lastTickRep = -1;
    _state = const WorkoutState(
      isRunning: true,
      isPaused: false,
      phase: WorkoutPhase.prep,
      currentSet: 1,
      currentRep: 0,
      phaseElapsedSeconds: 0.0,
      totalElapsedSeconds: 0.0,
    );
    _startTimer();
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void togglePause() {
    _state = _state.copyWith(isPaused: !_state.isPaused);
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void skipCurrentPhase() {
    HapticFeedback.lightImpact();
    switch (_state.phase) {
      case WorkoutPhase.prep:
        _enterWorkPhase(_state.currentSet);
        break;
      case WorkoutPhase.work:
        if (_state.currentSet < _config.sets) {
          _enterRestPhase(_state.currentSet);
        } else {
          _finishWorkout();
        }
        break;
      case WorkoutPhase.repRest:
        // Skip inter-rep rest directly into next work repetition
        _state = _state.copyWith(
          phase: WorkoutPhase.work,
          currentRep: _state.currentRep + 1,
          phaseElapsedSeconds: 0.0,
        );
        notifyListeners();
        break;
      case WorkoutPhase.rest:
        _enterWorkPhase(_state.currentSet + 1);
        break;
      case WorkoutPhase.finished:
        break;
    }
  }

  void stopWorkout() {
    _timer?.cancel();
    _state = _state.copyWith(isRunning: false, isPaused: false);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void resetToSetup() {
    _timer?.cancel();
    _state = const WorkoutState(isRunning: false, isPaused: false);
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    const interval = Duration(milliseconds: 50);
    const stepSeconds = 0.05;

    _timer = Timer.periodic(interval, (timer) {
      if (_state.isRunning && !_state.isPaused) {
        _tick(stepSeconds);
      }
    });
  }

  void _tick(double delta) {
    final cfg = _config;
    final cur = _state;

    final newTotalElapsed = cur.totalElapsedSeconds + delta;
    final newPhaseElapsed = cur.phaseElapsedSeconds + delta;

    switch (cur.phase) {
      case WorkoutPhase.prep:
        if (newPhaseElapsed >= cfg.prepTime) {
          _enterWorkPhase(cur.currentSet);
        } else {
          _state = cur.copyWith(
            phaseElapsedSeconds: newPhaseElapsed,
            totalElapsedSeconds: newTotalElapsed,
          );
          notifyListeners();
        }
        break;

      case WorkoutPhase.work:
        final repDuration = cfg.repDuration;

        if (newPhaseElapsed >= repDuration) {
          // One repetition completed!
          if (cur.currentRep >= cfg.reps) {
            // Set completed!
            _onSetCompleted(cur.currentSet);
          } else {
            // Move to next rep: check if inter-rep rest is configured
            if (cfg.repRestTime > 0) {
              _enterRepRestPhase(cur.currentSet, cur.currentRep);
            } else {
              HapticFeedback.lightImpact();
              SystemSound.play(SystemSoundType.click);
              _state = cur.copyWith(
                currentRep: cur.currentRep + 1,
                phaseElapsedSeconds: 0.0,
                totalElapsedSeconds: newTotalElapsed,
              );
              notifyListeners();
            }
          }
        } else {
          _state = cur.copyWith(
            phaseElapsedSeconds: newPhaseElapsed,
            totalElapsedSeconds: newTotalElapsed,
          );
          notifyListeners();
        }
        break;

      case WorkoutPhase.repRest:
        if (newPhaseElapsed >= cfg.repRestTime) {
          HapticFeedback.selectionClick();
          _state = cur.copyWith(
            phase: WorkoutPhase.work,
            currentRep: cur.currentRep + 1,
            phaseElapsedSeconds: 0.0,
            totalElapsedSeconds: newTotalElapsed,
          );
          notifyListeners();
        } else {
          _state = cur.copyWith(
            phaseElapsedSeconds: newPhaseElapsed,
            totalElapsedSeconds: newTotalElapsed,
          );
          notifyListeners();
        }
        break;

      case WorkoutPhase.rest:
        final restRemaining = cfg.restTime - newPhaseElapsed;
        final intRemaining = restRemaining.toInt();

        // 3-2-1 warning ticks
        if (intRemaining >= 1 &&
            intRemaining <= 3 &&
            intRemaining != _lastTickRep &&
            (restRemaining - intRemaining) < 0.1) {
          _lastTickRep = intRemaining;
          HapticFeedback.mediumImpact();
          SystemSound.play(SystemSoundType.click);
        }

        if (newPhaseElapsed >= cfg.restTime) {
          _enterWorkPhase(cur.currentSet + 1);
        } else {
          _state = cur.copyWith(
            phaseElapsedSeconds: newPhaseElapsed,
            totalElapsedSeconds: newTotalElapsed,
          );
          notifyListeners();
        }
        break;

      case WorkoutPhase.finished:
        break;
    }
  }

  void _enterRepRestPhase(int setNumber, int completedRep) {
    HapticFeedback.lightImpact();
    _state = _state.copyWith(
      phase: WorkoutPhase.repRest,
      currentSet: setNumber,
      currentRep: completedRep,
      phaseElapsedSeconds: 0.0,
    );
    notifyListeners();
  }

  void _onSetCompleted(int completedSet) {
    if (_config.vibrateOnSetComplete) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 150), () {
        HapticFeedback.heavyImpact();
      });
    } else {
      HapticFeedback.mediumImpact();
    }
    SystemSound.play(SystemSoundType.alert);

    if (completedSet < _config.sets) {
      _enterRestPhase(completedSet);
    } else {
      _finishWorkout();
    }
  }

  void _enterWorkPhase(int setNumber) {
    _lastTickRep = -1;
    if (_config.vibrateOnSetStart) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 120), () {
        HapticFeedback.mediumImpact();
      });
    } else {
      HapticFeedback.mediumImpact();
    }
    SystemSound.play(SystemSoundType.alert);
    _state = _state.copyWith(
      phase: WorkoutPhase.work,
      currentSet: setNumber,
      currentRep: 1,
      phaseElapsedSeconds: 0.0,
    );
    notifyListeners();
  }

  void _enterRestPhase(int finishedSet) {
    _lastTickRep = -1;
    _state = _state.copyWith(
      phase: WorkoutPhase.rest,
      currentSet: finishedSet,
      phaseElapsedSeconds: 0.0,
    );
    notifyListeners();
  }

  void _finishWorkout() {
    _timer?.cancel();
    HapticFeedback.vibrate();
    SystemSound.play(SystemSoundType.alert);
    _state = _state.copyWith(
      phase: WorkoutPhase.finished,
      phaseElapsedSeconds: 0.0,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
