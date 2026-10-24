import 'package:flutter/material.dart';

import '../controllers/workout_controller.dart';

class SetupScreen extends StatelessWidget {
  final WorkoutController controller;

  const SetupScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = controller.config;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'TempoFit',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: FilledButton.icon(
            onPressed: () => controller.startWorkout(),
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text(
              'Start Workout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: const StadiumBorder(),
              elevation: 4,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Presets Card
            Card(
              color: colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'QUICK PRESETS',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _PresetChip(
                            label: 'Hypertrophy (3x10 @ 4s)',
                            isSelected:
                                config.sets == 3 &&
                                config.reps == 10 &&
                                config.repDuration == 4 &&
                                config.restTime == 90,
                            onTap: () => controller.applyPreset(
                              sets: 3,
                              reps: 10,
                              duration: 4,
                              rest: 90,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _PresetChip(
                            label: 'Strength (5x5 @ 5s)',
                            isSelected:
                                config.sets == 5 &&
                                config.reps == 5 &&
                                config.repDuration == 5 &&
                                config.restTime == 120,
                            onTap: () => controller.applyPreset(
                              sets: 5,
                              reps: 5,
                              duration: 5,
                              rest: 120,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _PresetChip(
                            label: 'Endurance (4x15 @ 3s)',
                            isSelected:
                                config.sets == 4 &&
                                config.reps == 15 &&
                                config.repDuration == 3 &&
                                config.restTime == 60,
                            onTap: () => controller.applyPreset(
                              sets: 4,
                              reps: 15,
                              duration: 3,
                              rest: 60,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _PresetChip(
                            label: 'Speed / Power (4x6 @ 2s)',
                            isSelected:
                                config.sets == 4 &&
                                config.reps == 6 &&
                                config.repDuration == 2 &&
                                config.restTime == 75,
                            onTap: () => controller.applyPreset(
                              sets: 4,
                              reps: 6,
                              duration: 2,
                              rest: 75,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Number of Sets
            _ConfigCounterCard(
              title: 'TOTAL SETS',
              subtitle: 'Number of workout intervals',
              icon: Icons.layers_rounded,
              valueText: '${config.sets}',
              unitText: 'SETS',
              onDecrement: () => controller.updateSets(-1),
              onIncrement: () => controller.updateSets(1),
            ),
            const SizedBox(height: 12),

            // Reps Per Set
            _ConfigCounterCard(
              title: 'REPS PER SET',
              subtitle: 'Repetitions target per cycle',
              icon: Icons.repeat_rounded,
              valueText: '${config.reps}',
              unitText: 'REPS',
              onDecrement: () => controller.updateReps(-1),
              onIncrement: () => controller.updateReps(1),
            ),
            const SizedBox(height: 12),

            // Cadence / Rep Duration
            _ConfigCounterCard(
              title: 'REP CADENCE',
              subtitle: 'Paced seconds per single repetition',
              icon: Icons.speed_rounded,
              valueText: '${config.repDuration}',
              unitText: 'SEC / REP',
              onDecrement: () => controller.updateRepDuration(-1),
              onIncrement: () => controller.updateRepDuration(1),
            ),
            const SizedBox(height: 12),

            // Rest Interval
            _ConfigCounterCard(
              title: 'REST TIME',
              subtitle: 'Recovery period between completed sets',
              icon: Icons.timer_rounded,
              valueText: '${config.restTime}',
              unitText: 'SECONDS',
              onDecrement: () => controller.updateRestTime(-5),
              onIncrement: () => controller.updateRestTime(5),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => onTap(),
      shape: const StadiumBorder(),
      showCheckmark: true,
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ConfigCounterCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String valueText;
  final String unitText;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _ConfigCounterCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.valueText,
    required this.unitText,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        valueText,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        unitText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: onDecrement,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                minimumSize: const Size(44, 44),
              ),
              child: const Icon(Icons.remove_rounded, size: 20),
            ),
            const SizedBox(width: 4),
            FilledButton.tonal(
              onPressed: onIncrement,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                minimumSize: const Size(44, 44),
              ),
              child: const Icon(Icons.add_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
