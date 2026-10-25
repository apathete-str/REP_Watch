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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 44,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Rep Watch Complete!',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'All targeted sets & cadence cycles finished.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _StatCard(title: 'SETS', value: '${config.sets}'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(title: 'REPS', value: '$totalReps'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(title: 'TIME', value: durationStr),
                ),
              ],
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: const StadiumBorder(),
                elevation: 3,
              ),
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                'Complete & Return',
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
        child: Column(
          children: [
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
