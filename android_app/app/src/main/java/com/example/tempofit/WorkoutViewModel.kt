package com.example.tempofit

import android.content.Context
import android.media.AudioAttributes
import android.media.SoundPool
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class WorkoutViewModel : ViewModel() {

    private val _config = MutableStateFlow(WorkoutConfig())
    val config: StateFlow<WorkoutConfig> = _config.asStateFlow()

    private val _state = MutableStateFlow(WorkoutState())
    val state: StateFlow<WorkoutState> = _state.asStateFlow()

    private var timerJob: Job? = null
    private var lastTickRep: Int = -1

    // Sound & Haptic callbacks
    var onRepCompleted: (() -> Unit)? = null
    var onSetCompleted: (() -> Unit)? = null
    var onRestCountdownTick: (() -> Unit)? = null

    // Configuration modifiers
    fun updateSets(delta: Int) {
        _config.update { it.copy(sets = (it.sets + delta).coerceIn(1, 50)) }
    }

    fun updateReps(delta: Int) {
        _config.update { it.copy(reps = (it.reps + delta).coerceIn(1, 100)) }
    }

    fun updateRepDuration(delta: Int) {
        _config.update { it.copy(repDuration = (it.repDuration + delta).coerceIn(1, 30)) }
    }

    fun updateRestTime(delta: Int) {
        _config.update { it.copy(restTime = (it.restTime + delta).coerceIn(5, 600)) }
    }

    fun applyPreset(sets: Int, reps: Int, duration: Int, rest: Int) {
        _config.value = WorkoutConfig(
            sets = sets,
            reps = reps,
            repDuration = duration,
            restTime = rest
        )
    }

    fun startWorkout() {
        lastTickRep = -1
        _state.value = WorkoutState(
            isRunning = true,
            isPaused = false,
            phase = WorkoutPhase.PREP,
            currentSet = 1,
            currentRep = 0,
            phaseElapsedSeconds = 0f,
            totalElapsedSeconds = 0f
        )
        startTimer()
    }

    fun togglePause() {
        _state.update { it.copy(isPaused = !it.isPaused) }
    }

    fun skipCurrentPhase() {
        val current = _state.value
        when (current.phase) {
            WorkoutPhase.PREP -> {
                enterWorkPhase(current.currentSet)
            }
            WorkoutPhase.WORK -> {
                if (current.currentSet < _config.value.sets) {
                    enterRestPhase(current.currentSet)
                } else {
                    finishWorkout()
                }
            }
            WorkoutPhase.REST -> {
                enterWorkPhase(current.currentSet + 1)
            }
            WorkoutPhase.FINISHED -> {}
        }
    }

    fun stopWorkout() {
        timerJob?.cancel()
        _state.update { it.copy(isRunning = false, isPaused = false) }
    }

    private fun startTimer() {
        timerJob?.cancel()
        timerJob = viewModelScope.launch {
            val stepIntervalMs = 50L
            val stepSeconds = stepIntervalMs / 1000f

            while (isActive) {
                delay(stepIntervalMs)
                if (_state.value.isRunning && !_state.value.isPaused) {
                    tick(stepSeconds)
                }
            }
        }
    }

    private fun tick(delta: Float) {
        val cfg = _config.value
        val cur = _state.value

        val newTotalElapsed = cur.totalElapsedSeconds + delta
        val newPhaseElapsed = cur.phaseElapsedSeconds + delta

        when (cur.phase) {
            WorkoutPhase.PREP -> {
                if (newPhaseElapsed >= cfg.prepTime) {
                    enterWorkPhase(cur.currentSet)
                } else {
                    _state.update {
                        it.copy(
                            phaseElapsedSeconds = newPhaseElapsed,
                            totalElapsedSeconds = newTotalElapsed
                        )
                    }
                }
            }
            WorkoutPhase.WORK -> {
                val repDuration = cfg.repDuration
                val totalWorkDuration = cfg.reps * repDuration

                // Current rep calculation: 0s to 4s is rep 1, 4s to 8s is rep 2, etc.
                val repIndex = ((newPhaseElapsed / repDuration).toInt() + 1).coerceAtMost(cfg.reps)

                if (repIndex != cur.currentRep && repIndex <= cfg.reps) {
                    if (repIndex > 1) {
                        onRepCompleted?.invoke()
                    }
                }

                if (newPhaseElapsed >= totalWorkDuration) {
                    onRepCompleted?.invoke()
                    if (cur.currentSet < cfg.sets) {
                        enterRestPhase(cur.currentSet)
                    } else {
                        finishWorkout()
                    }
                } else {
                    _state.update {
                        it.copy(
                            currentRep = repIndex,
                            phaseElapsedSeconds = newPhaseElapsed,
                            totalElapsedSeconds = newTotalElapsed
                        )
                    }
                }
            }
            WorkoutPhase.REST -> {
                val restRemaining = cfg.restTime - newPhaseElapsed
                val intRemaining = restRemaining.toInt()

                // Trigger countdown ticks at 3, 2, 1
                if (intRemaining in 1..3 && intRemaining != lastTickRep && (restRemaining - intRemaining) < 0.1f) {
                    lastTickRep = intRemaining
                    onRestCountdownTick?.invoke()
                }

                if (newPhaseElapsed >= cfg.restTime) {
                    enterWorkPhase(cur.currentSet + 1)
                } else {
                    _state.update {
                        it.copy(
                            phaseElapsedSeconds = newPhaseElapsed,
                            totalElapsedSeconds = newTotalElapsed
                        )
                    }
                }
            }
            WorkoutPhase.FINISHED -> {}
        }
    }

    private fun enterWorkPhase(setNumber: Int) {
        lastTickRep = -1
        _state.update {
            it.copy(
                phase = WorkoutPhase.WORK,
                currentSet = setNumber,
                currentRep = 1,
                phaseElapsedSeconds = 0f
            )
        }
    }

    private fun enterRestPhase(finishedSet: Int) {
        lastTickRep = -1
        onSetCompleted?.invoke()
        _state.update {
            it.copy(
                phase = WorkoutPhase.REST,
                currentSet = finishedSet,
                phaseElapsedSeconds = 0f
            )
        }
    }

    private fun finishWorkout() {
        onSetCompleted?.invoke()
        _state.update {
            it.copy(
                phase = WorkoutPhase.FINISHED,
                phaseElapsedSeconds = 0f
            )
        }
    }
}

