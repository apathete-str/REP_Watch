
import 'package:flutter/material.dart';

import '../controllers/workout_controller.dart';
import '../models/workout_model.dart';
import '../theme/app_theme.dart';
import '../widgets/squibbly_decorations.dart';
import 'summary_modal.dart';

class WorkoutScreen extends StatefulWidget {
  final WorkoutController controller;

  const WorkoutScreen({super.key, required this.controller});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _squibblyAnim;

  @override
  void initState() {
    super.initState();
    _squibblyAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _squibblyAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
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
      WorkoutPhase.repRest => AppTheme.repRestPurple,
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
        return (state.phaseElapsedSeconds / config.repDuration).clamp(0.0, 1.0);
      }(),
      WorkoutPhase.repRest => () {
        if (config.repRestTime <= 0) return 0.0;
        final remain = (config.repRestTime - state.phaseElapsedSeconds).clamp(
          0.0,
          config.repRestTime.toDouble(),
        );
        return ((config.repRestTime - remain) / config.repRestTime).clamp(0.0, 1.0);
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
      WorkoutPhase.work => (state.phaseElapsedSeconds / config.repDuration).clamp(0.0, 1.0),
      WorkoutPhase.repRest => 1.0,
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
      body: Stack(
        children: [
          // Background squibbly animated organic wave
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _squibblyAnim,
              builder: (context, _) {
                return CustomPaint(
                  painter: SquibblyWavePainter(
                    animationValue: _squibblyAnim.value,
                    primaryColor: phaseColor,
                    secondaryColor: colorScheme.tertiary,
                    alpha: 0.08,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  // Header Status Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.layers_rounded,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SET ${state.currentSet} / ${config.sets}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'TOTAL $totalDurationStr',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Circular Cadence and Phase Ring with Squibbly Aura
                  Center(
                    child: SizedBox(
                      width: 290,
                      height: 290,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Squibbly organic pulsing halo
                          AnimatedBuilder(
                            animation: _squibblyAnim,
                            builder: (context, _) {
                              return CustomPaint(
                                size: const Size(280, 280),
                                painter: SquibblyBlobPainter(
                                  animationValue: _squibblyAnim.value,
                                  color: phaseColor.withValues(alpha: 0.12),
                                  style: PaintingStyle.stroke,
                                  strokeWidth: 4,
                                ),
                              );
                            },
                          ),
                          // Outer Background Track
                          SizedBox(
                            width: 250,
                            height: 250,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 16,
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          // Phase Progress Indicator: direct value for lag-free 60/120fps
                          SizedBox(
                            width: 250,
                            height: 250,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 16,
                              strokeCap: StrokeCap.round,
                              color: phaseColor,
                            ),
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
                                WorkoutPhase.repRest => 'PAUSE / REP REST',
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
                          ] else if (state.phase == WorkoutPhase.repRest) ...[
                            Text(
                              '${(config.repRestTime - state.phaseElapsedSeconds).ceil().clamp(1, config.repRestTime)}',
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 68,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.repRestPurple,
                              ),
                            ),
                            Text(
                              'INTER-REP PAUSE (NEXT REP: ${state.currentRep + 1})',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
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

              // Rhythm / Cadence Progress Bar (during WORK or REP REST phase)
              if (state.phase == WorkoutPhase.work || state.phase == WorkoutPhase.repRest) ...[
                Card(
                  color: colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.phase == WorkoutPhase.repRest
                                  ? 'INTER-REP REST'
                                  : 'REP RHYTHM CADENCE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              state.phase == WorkoutPhase.repRest
                                  ? '${state.phaseElapsedSeconds.toStringAsFixed(1)}s / ${config.repRestTime}s'
                                  : '${state.phaseElapsedSeconds.toStringAsFixed(1)}s / ${config.repDuration}s',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: state.phase == WorkoutPhase.repRest
                                    ? AppTheme.repRestPurple
                                    : AppTheme.workGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: repCadenceProgress,
                            minHeight: 14,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            color: state.phase == WorkoutPhase.repRest
                                ? AppTheme.repRestPurple
                                : AppTheme.workGreen,
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
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 14.0,
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
                            WorkoutPhase.work => config.repRestTime > 0
                                ? 'Next: ${config.repRestTime}s pause between reps'
                                : state.currentSet < config.sets
                                    ? 'Next: Rest Interval (${config.restTime}s)'
                                    : 'Final set in progress! Finish strong!',
                            WorkoutPhase.repRest =>
                              'Next up: Repetition ${state.currentRep + 1} of ${config.reps}',
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
    ],
  ),
);
      },
    );
  }
}
