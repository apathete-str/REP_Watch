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

  void updateRestTime(int delta) {
    final newRest = (_config.restTime + delta).clamp(5, 600);
    _config = _config.copyWith(restTime: newRest);
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
        final totalWorkDuration = cfg.reps * repDuration;

        final repIndex = ((newPhaseElapsed / repDuration).toInt() + 1).clamp(1, cfg.reps);

        if (repIndex != cur.currentRep && repIndex <= cfg.reps) {
          if (repIndex > 1) {
            HapticFeedback.lightImpact();
            SystemSound.play(SystemSoundType.click);
          }
        }

        if (newPhaseElapsed >= totalWorkDuration) {
          HapticFeedback.heavyImpact();
          SystemSound.play(SystemSoundType.alert);
          if (cur.currentSet < cfg.sets) {
            _enterRestPhase(cur.currentSet);
          } else {
            _finishWorkout();
          }
        } else {
          _state = cur.copyWith(
            currentRep: repIndex,
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
        if (intRemaining >= 1 && intRemaining <= 3 && intRemaining != _lastTickRep && (restRemaining - intRemaining) < 0.1) {
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

  void _enterWorkPhase(int setNumber) {
    _lastTickRep = -1;
    HapticFeedback.heavyImpact();
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
