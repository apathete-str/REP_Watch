package com.example.tempofit

enum class WorkoutPhase {
    PREP,
    WORK,
    REST,
    FINISHED
}

data class WorkoutConfig(
    val sets: Int = 3,
    val reps: Int = 10,
    val repDuration: Int = 4,   // 4s per rep
    val restTime: Int = 90,     // 90s rest
    val prepTime: Int = 3       // 3s get ready
)

data class WorkoutState(
    val isRunning: Boolean = false,
    val isPaused: Boolean = false,
    val phase: WorkoutPhase = WorkoutPhase.PREP,
    val currentSet: Int = 1,
    val currentRep: Int = 0,
    val phaseElapsedSeconds: Float = 0f,
    val totalElapsedSeconds: Float = 0f
)

