
import 'package:flutter/material.dart';

import '../controllers/workout_controller.dart';
import '../models/workout_model.dart';
import '../theme/app_theme.dart';
import 'summary_modal.dart';

class WorkoutScreen extends StatelessWidget {
  final WorkoutController controller;

  const WorkoutScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = controller.config;
    final state = controller.state;

    // Show summary modal when finished
    if (state.phase == WorkoutPhase.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => SummaryModal(
            config: config,
            state: state,
            onDone: () {
              Navigator.of(ctx).pop();
              controller.resetToSetup();
            },
          ),
        );
      });
    }

    final phaseColor = switch (state.phase) {
      WorkoutPhase.prep => AppTheme.prepCyan,
      WorkoutPhase.work => AppTheme.workGreen,
      WorkoutPhase.rest => AppTheme.restOrange,
      WorkoutPhase.finished => colorScheme.primary,
    };

    final progress = switch (state.phase) {
      WorkoutPhase.prep => () {
        final remain = (config.prepTime - state.phaseElapsedSeconds).clamp(
          0.0,
          config.prepTime.toDouble(),
        );
        return ((config.prepTime - remain) / config.prepTime).clamp(0.0, 1.0);
      }(),
      WorkoutPhase.work => () {
        final totalSetTime = (config.reps * config.repDuration).toDouble();
        return (state.phaseElapsedSeconds / totalSetTime).clamp(0.0, 1.0);
      }(),
      WorkoutPhase.rest => () {
        final remain = (config.restTime - state.phaseElapsedSeconds).clamp(
          0.0,
          config.restTime.toDouble(),
        );
        return (remain / config.restTime).clamp(0.0, 1.0);
      }(),
      WorkoutPhase.finished => 1.0,
    };

    final repCadenceProgress = switch (state.phase) {
      WorkoutPhase.work => () {
        final currentRepOffset = state.phaseElapsedSeconds % config.repDuration;
        return (currentRepOffset / config.repDuration).clamp(0.0, 1.0);
      }(),
      _ => 0.0,
    };

    final totalSeconds = state.totalElapsedSeconds.toInt();
    final tm = totalSeconds ~/ 60;
    final ts = totalSeconds % 60;
    final totalDurationStr =
        '${tm.toString().padLeft(2, '0')}:${ts.toString().padLeft(2, '0')}';

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            children: [
              // Stop Workout
              IconButton.filledTonal(
                onPressed: () => controller.stopWorkout(),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                  minimumSize: const Size(56, 56),
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.close_rounded, size: 28),
                tooltip: 'Stop Workout',
              ),
              const SizedBox(width: 14),

              // Play / Pause Button
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => controller.togglePause(),
                  style: FilledButton.styleFrom(
                    backgroundColor: state.isPaused
                        ? colorScheme.primary
                        : colorScheme.secondaryContainer,
                    foregroundColor: state.isPaused
                        ? colorScheme.onPrimary
                        : colorScheme.onSecondaryContainer,
                    minimumSize: const Size.fromHeight(56),
                    shape: const StadiumBorder(),
                    elevation: 3,
                  ),
                  icon: Icon(
                    state.isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    size: 28,
                  ),
                  label: Text(
                    state.isPaused ? 'Resume' : 'Pause',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Skip Phase
              IconButton.filledTonal(
                onPressed: () => controller.skipCurrentPhase(),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  foregroundColor: colorScheme.onSurfaceVariant,
                  minimumSize: const Size(56, 56),
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.skip_next_rounded, size: 28),
                tooltip: 'Skip Phase',
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // Header Status Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.layers_outlined,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SET ${state.currentSet} / ${config.sets}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TOTAL $totalDurationStr',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Circular Cadence and Phase Ring
              Center(
                child: SizedBox(
                  width: 270,
                  height: 270,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Background Track
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 14,
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      // Animated Phase Progress Indicator
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: progress),
                        duration: const Duration(milliseconds: 100),
                        builder: (context, val, child) {
                          return SizedBox(
                            width: 260,
                            height: 260,
                            child: CircularProgressIndicator(
                              value: val,
                              strokeWidth: 14,
                              strokeCap: StrokeCap.round,
                              color: phaseColor,
                            ),
                          );
                        },
                      ),
                      // Center Content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Phase Badge
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: phaseColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              switch (state.phase) {
                                WorkoutPhase.prep => 'GET READY',
                                WorkoutPhase.work => 'WORKING',
                                WorkoutPhase.rest => 'RECOVERY REST',
                                WorkoutPhase.finished => 'COMPLETED',
                              },
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: phaseColor,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Dynamic Rep or Time readout
                          if (state.phase == WorkoutPhase.prep) ...[
                            Text(
                              '${(config.prepTime - state.phaseElapsedSeconds).ceil().clamp(1, config.prepTime)}',
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 68,
                                fontWeight: FontWeight.w900,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'SECONDS',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ] else if (state.phase == WorkoutPhase.work) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${state.currentRep}',
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontSize: 68,
                                    fontWeight: FontWeight.w900,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  ' / ${config.reps}',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                            Text(
                              'REPETITIONS',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ] else if (state.phase == WorkoutPhase.rest) ...[
                            () {
                              final remain =
                                  (config.restTime - state.phaseElapsedSeconds)
                                      .ceil()
                                      .clamp(0, config.restTime);
                              final rm = remain ~/ 60;
                              final rs = remain % 60;
                              final rStr =
                                  '${rm.toString().padLeft(2, '0')}:${rs.toString().padLeft(2, '0')}';
                              return Column(
                                children: [
                                  Text(
                                    rStr,
                                    style: theme.textTheme.displayMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: colorScheme.onSurface,
                                        ),
                                  ),
                                  Text(
                                    'TIME REMAINING',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              );
                            }(),
                          ] else ...[
                            Text(
                              'DONE!',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Rhythm / Cadence Progress Bar (only during WORK phase)
              if (state.phase == WorkoutPhase.work) ...[
                Card(
                  color: colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 14.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'REP RHYTHM CADENCE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${(state.phaseElapsedSeconds % config.repDuration).toStringAsFixed(1)}s / ${config.repDuration}s',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.workGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: repCadenceProgress,
                            ),
                            duration: const Duration(milliseconds: 60),
                            builder: (context, val, child) {
                              return LinearProgressIndicator(
                                value: val,
                                minHeight: 12,
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                                color: AppTheme.workGreen,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Next Phase Preview Card
              Card(
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          switch (state.phase) {
                            WorkoutPhase.prep =>
                              'Set 1 starting immediately after countdown',
                            WorkoutPhase.work =>
                              state.currentSet < config.sets
                                  ? 'Next up: Rest Interval (${config.restTime}s)'
                                  : 'Final set in progress! Finish strong!',
                            WorkoutPhase.rest =>
                              'Next up: Set ${state.currentSet + 1} of ${config.sets}',
                            WorkoutPhase.finished => 'Workout Complete',
                          },
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
