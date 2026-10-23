package com.example.tempofit.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.EmojiEvents
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.tempofit.WorkoutConfig
import com.example.tempofit.WorkoutState
import java.util.Locale

@Composable
fun SummaryModal(
    config: WorkoutConfig,
    state: WorkoutState,
    onDone: () -> Unit
) {
    val totalReps = config.sets * config.reps
    val totalSeconds = state.totalElapsedSeconds.toInt()
    val m = totalSeconds / 60
    val s = totalSeconds % 60
    val durationStr = String.format(Locale.US, "%02d:%02d", m, s)

    AlertDialog(
        onDismissRequest = onDone,
        confirmButton = {
            Button(
                onClick = onDone,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                shape = CircleShape,
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    contentColor = MaterialTheme.colorScheme.onPrimary
                )
            ) {
                Icon(imageVector = Icons.Default.Check, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text(text = "Done", fontWeight = FontWeight.Bold, fontSize = 16.sp)
            }
        },
        icon = {
            Box(
                modifier = Modifier
                    .size(64.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.primaryContainer),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.EmojiEvents,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onPrimaryContainer,
                    modifier = Modifier.size(36.dp)
                )
            }
        },
        title = {
            Text(
                text = "Crushed It!",
                fontWeight = FontWeight.ExtraBold,
                style = MaterialTheme.typography.headlineSmall,
                color = MaterialTheme.colorScheme.onSurface
            )
        },
        text = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 8.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Text(
                    text = "Workout completed successfully.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    StatCard(
                        title = "SETS",
                        value = "${config.sets}",
                        modifier = Modifier.weight(1f)
                    )
                    StatCard(
                        title = "TOTAL REPS",
                        value = "$totalReps",
                        modifier = Modifier.weight(1f)
                    )
                }

                StatCard(
                    title = "TOTAL WORKOUT TIME",
                    value = durationStr,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        shape = RoundedCornerShape(28.dp),
        containerColor = MaterialTheme.colorScheme.surfaceContainerHigh
    )
}

