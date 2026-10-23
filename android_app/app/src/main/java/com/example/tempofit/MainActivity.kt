package com.example.tempofit

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.animation.Crossfade
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import com.example.tempofit.ui.SetupScreen
import com.example.tempofit.ui.SummaryModal
import com.example.tempofit.ui.WorkoutScreen
import com.example.tempofit.ui.theme.TempoFitTheme

class MainActivity : ComponentActivity() {

    private val viewModel: WorkoutViewModel by viewModels()
    private lateinit var soundAndHaptics: SoundAndHaptics

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        // Keep screen on during workouts
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        soundAndHaptics = SoundAndHaptics(this)
        viewModel.onRepCompleted = { soundAndHaptics.playRepBeep() }
        viewModel.onSetCompleted = { soundAndHaptics.playSetComplete() }
        viewModel.onRestCountdownTick = { soundAndHaptics.playRestCountdownTick() }

        setContent {
            TempoFitTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    TempoFitApp(viewModel)
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        soundAndHaptics.release()
    }
}

@Composable
fun TempoFitApp(viewModel: WorkoutViewModel) {
    val config by viewModel.config.collectAsState()
    val state by viewModel.state.collectAsState()

    Crossfade(targetState = state.isRunning, label = "screenTransition") { isRunning ->
        if (!isRunning) {
            SetupScreen(
                config = config,
                onUpdateSets = viewModel::updateSets,
                onUpdateReps = viewModel::updateReps,
                onUpdateTempo = viewModel::updateRepDuration,
                onUpdateRest = viewModel::updateRestTime,
                onApplyPreset = viewModel::applyPreset,
                onStartWorkout = viewModel::startWorkout
            )
        } else {
            WorkoutScreen(
                config = config,
                state = state,
                onPauseToggle = viewModel::togglePause,
                onSkip = viewModel::skipCurrentPhase,
                onStop = viewModel::stopWorkout
            )

            if (state.phase == WorkoutPhase.FINISHED) {
                SummaryModal(
                    config = config,
                    state = state,
                    onDone = viewModel::stopWorkout
                )
            }
        }
    }
}

