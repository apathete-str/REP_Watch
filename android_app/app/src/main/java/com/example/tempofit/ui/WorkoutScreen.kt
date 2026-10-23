package com.example.tempofit.ui

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.tempofit.WorkoutConfig
import com.example.tempofit.WorkoutPhase
import com.example.tempofit.WorkoutState
import com.example.tempofit.ui.theme.PrepCyan
import com.example.tempofit.ui.theme.RestOrange
import com.example.tempofit.ui.theme.WorkGreen
import java.util.Locale

@Composable
fun WorkoutScreen(
    config: WorkoutConfig,
    state: WorkoutState,
    onPauseToggle: () -> Unit,
    onSkip: () -> Unit,
    onStop: () -> Unit
) {
    val phaseColor by animateColorAsState(
        targetValue = when (state.phase) {
            WorkoutPhase.PREP -> PrepCyan
            WorkoutPhase.WORK -> WorkGreen
            WorkoutPhase.REST -> RestOrange
            WorkoutPhase.FINISHED -> MaterialTheme.colorScheme.primary
        },
        label = "phaseColorAnim"
    )

    // Calculate ring and progress
    val progress = when (state.phase) {
        WorkoutPhase.PREP -> {
            val remain = (config.prepTime - state.phaseElapsedSeconds).coerceAtLeast(0f)
            (config.prepTime - remain) / config.prepTime
        }
        WorkoutPhase.WORK -> {
            val totalSetTime = (config.reps * config.repDuration).toFloat()
            (state.phaseElapsedSeconds / totalSetTime).coerceIn(0f, 1f)
        }
        WorkoutPhase.REST -> {
            val remain = (config.restTime - state.phaseElapsedSeconds).coerceAtLeast(0f)
            (remain / config.restTime).coerceIn(0f, 1f)
        }
        WorkoutPhase.FINISHED -> 1f
    }

    val animatedProgress by animateFloatAsState(
        targetValue = progress,
        animationSpec = tween(durationMillis = 100),
        label = "ringProgressAnim"
    )

    Scaffold(
        bottomBar = {
            // Material 3 Control Bar
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 20.dp),
                color = Color.Transparent
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Stop / Quit Button
                    IconButton(
                        onClick = onStop,
                        modifier = Modifier
                            .size(56.dp)
                            .background(
                                color = MaterialTheme.colorScheme.errorContainer,
                                shape = CircleShape
                            )
                    ) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Stop Workout",
                            tint = MaterialTheme.colorScheme.onErrorContainer
                        )
                    }

                    // Main Play/Pause Button (Material 3 Extended FAB style)
                    Button(
                        onClick = onPauseToggle,
                        modifier = Modifier
                            .weight(1f)
                            .height(56.dp),
                        shape = CircleShape,
                        colors = ButtonDefaults.buttonColors(
                            containerColor = if (state.isPaused) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.secondaryContainer,
                            contentColor = if (state.isPaused) MaterialTheme.colorScheme.onPrimary else MaterialTheme.colorScheme.onSecondaryContainer
                        ),
                        elevation = ButtonDefaults.buttonElevation(defaultElevation = 4.dp)
                    ) {
                        Icon(
                            imageVector = if (state.isPaused) Icons.Default.PlayArrow else Icons.Default.Pause,
                            contentDescription = if (state.isPaused) "Resume" else "Pause",
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = if (state.isPaused) "Resume" else "Pause",
                            fontSize = 17.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    // Skip Button
                    IconButton(
                        onClick = onSkip,
                        modifier = Modifier
                            .size(56.dp)
                            .background(
                                color = MaterialTheme.colorScheme.surfaceContainerHigh,
                                shape = CircleShape
                            )
                    ) {
                        Icon(
                            imageVector = Icons.Default.SkipNext,
                            contentDescription = "Skip Phase",
                            tint = MaterialTheme.colorScheme.onSurface
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 20.dp, vertical = 12.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Status Chip
            AssistChip(
                onClick = {},
                label = {
                    Text(
                        text = when (state.phase) {
                            WorkoutPhase.PREP -> "GET READY"
                            WorkoutPhase.WORK -> "SET ${state.currentSet} ACTIVE"
                            WorkoutPhase.REST -> "REST INTERVAL"
                            WorkoutPhase.FINISHED -> "WORKOUT COMPLETE"
                        },
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp,
                        color = phaseColor
                    )
                },
                leadingIcon = {
                    Icon(
                        imageVector = when (state.phase) {
                            WorkoutPhase.PREP -> Icons.Default.Timelapse
                            WorkoutPhase.WORK -> Icons.Default.FitnessCenter
                            WorkoutPhase.REST -> Icons.Default.Bedtime
                            WorkoutPhase.FINISHED -> Icons.Default.EmojiEvents
                        },
                        contentDescription = null,
                        tint = phaseColor,
                        modifier = Modifier.size(18.dp)
                    )
                },
                shape = CircleShape,
                colors = AssistChipDefaults.assistChipColors(
                    containerColor = phaseColor.copy(alpha = 0.12f)
                ),
                border = AssistChipDefaults.assistChipBorder(
                    enabled = true,
                    borderColor = phaseColor.copy(alpha = 0.35f)
                )
            )

            // Center Circular Progress and Rep/Timer Hero
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(290.dp)
                    .padding(8.dp)
            ) {
                // Background Track
                CircularProgressIndicator(
                    progress = { 1f },
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.surfaceContainerHighest,
                    strokeWidth = 14.dp,
                    strokeCap = StrokeCap.Round
                )
                // Active Animated Progress
                CircularProgressIndicator(
                    progress = { animatedProgress },
                    modifier = Modifier.fillMaxSize(),
                    color = phaseColor,
                    strokeWidth = 14.dp,
                    strokeCap = StrokeCap.Round
                )

                // Hero Texts
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Text(
                        text = when (state.phase) {
                            WorkoutPhase.PREP -> "STARTING IN"
                            WorkoutPhase.WORK -> "CURRENT REP"
                            WorkoutPhase.REST -> "REST TIME"
                            WorkoutPhase.FINISHED -> "TOTAL TIME"
                        },
                        style = MaterialTheme.typography.labelMedium,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.2.sp,
                        color = MaterialTheme.colorScheme.outline
                    )

                    AnimatedContent(
                        targetState = when (state.phase) {
                            WorkoutPhase.PREP -> {
                                val s = (config.prepTime - state.phaseElapsedSeconds).toInt() + 1
                                if (s > 0) "$s" else "GO!"
                            }
                            WorkoutPhase.WORK -> "${state.currentRep}"
                            WorkoutPhase.REST -> {
                                val r = (config.restTime - state.phaseElapsedSeconds).coerceAtLeast(0f).toInt()
                                formatSeconds(r)
                            }
                            WorkoutPhase.FINISHED -> formatSeconds(state.totalElapsedSeconds.toInt())
                        },
                        label = "heroTextAnim"
                    ) { primaryText ->
                        Text(
                            text = primaryText,
                            fontSize = 76.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                    }

                    Text(
                        text = when (state.phase) {
                            WorkoutPhase.PREP -> "Set 1 of ${config.sets}"
                            WorkoutPhase.WORK -> "Target: ${config.reps} reps (${config.repDuration}s cadence)"
                            WorkoutPhase.REST -> "Next: Set ${state.currentSet + 1} of ${config.sets}"
                            WorkoutPhase.FINISHED -> "Crushed it!"
                        },
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.Medium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            // Rep Cadence Rhythm Bar
            Surface(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(20.dp),
                color = MaterialTheme.colorScheme.surfaceContainer
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    val repRemainSec = (config.repDuration - (state.phaseElapsedSeconds % config.repDuration)).coerceAtLeast(0f)
                    val cadenceProgress = if (state.phase == WorkoutPhase.WORK) {
                        ((state.phaseElapsedSeconds % config.repDuration) / config.repDuration).coerceIn(0f, 1f)
                    } else if (state.phase == WorkoutPhase.REST) {
                        val restRemain = (config.restTime - state.phaseElapsedSeconds).coerceAtLeast(0f)
                        (restRemain / config.restTime).coerceIn(0f, 1f)
                    } else {
                        progress
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = if (state.phase == WorkoutPhase.WORK) "Rep Cadence" else "Phase Progress",
                            style = MaterialTheme.typography.labelMedium,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            text = if (state.phase == WorkoutPhase.WORK) {
                                String.format(Locale.US, "%.1fs in rep", repRemainSec)
                            } else if (state.phase == WorkoutPhase.REST) {
                                "${(config.restTime - state.phaseElapsedSeconds).toInt()}s left"
                            } else "",
                            style = MaterialTheme.typography.labelSmall,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.primary
                        )
                    }

                    LinearProgressIndicator(
                        progress = { cadenceProgress },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(8.dp)
                            .clip(CircleShape),
                        color = phaseColor,
                        trackColor = MaterialTheme.colorScheme.surfaceContainerHighest,
                        strokeCap = StrokeCap.Round
                    )
                }
            }

            // Stats row (Set, Rep, Elapsed)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                StatCard(
                    title = "SET",
                    value = "${state.currentSet}/${config.sets}",
                    modifier = Modifier.weight(1f)
                )
                StatCard(
                    title = "REP",
                    value = "${state.currentRep}/${config.reps}",
                    modifier = Modifier.weight(1f)
                )
                StatCard(
                    title = "TOTAL TIME",
                    value = formatSeconds(state.totalElapsedSeconds.toInt()),
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}

@Composable
fun StatCard(
    title: String,
    value: String,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier,
        shape = RoundedCornerShape(16.dp),
        color = MaterialTheme.colorScheme.surfaceContainer
    ) {
        Column(
            modifier = Modifier.padding(vertical = 12.dp, horizontal = 6.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.labelSmall,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.outline
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = value,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface
            )
        }
    }
}

private fun formatSeconds(seconds: Int): String {
    val m = seconds / 60
    val s = seconds % 60
    return String.format(Locale.US, "%02d:%02d", m, s)
}

