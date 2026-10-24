import 'package:flutter/material.dart';

import '../models/workout_model.dart';

class SummaryModal extends StatelessWidget {
  final WorkoutConfig config;
  final WorkoutState state;
  final VoidCallback onDone;

  const SummaryModal({
    super.key,
    required this.config,
    required this.state,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalReps = config.sets * config.reps;
    final totalSeconds = state.totalElapsedSeconds.toInt();
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    final durationStr =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Crushed It!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Workout completed successfully.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatCard(title: 'SETS', value: '${config.sets}'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(title: 'TOTAL REPS', value: '$totalReps'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(title: 'TIME', value: durationStr),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.check_rounded),
              label: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Column(
          children: [
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
