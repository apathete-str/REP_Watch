import 'package:flutter/material.dart';

import '../controllers/workout_controller.dart';
import '../widgets/rep_watch_logo.dart';
import 'add_preset_sheet.dart';

class SetupScreen extends StatelessWidget {
  final WorkoutController controller;

  const SetupScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final config = controller.config;

        return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const RepWatchLogo(size: 42, animate: true),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rep Watch',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                Text(
                  'Tempo Cadence Interval Pacer',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
              minimumSize: const Size.fromHeight(60),
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
            // Presets Card: firmly wrapped inside the Quick Preset card container
            Card(
              color: colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.bolt_rounded,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'QUICK PRESETS',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            AddPresetSheet.show(
                              context: context,
                              initialConfig: controller.config,
                              onSave: (name, newConfig) {
                                controller.addCustomPreset(
                                  name: name,
                                  config: newConfig,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Saved preset "$name"'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          style: FilledButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 36),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text(
                            'Add Preset',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Wrapped layout so presets are securely aligned and contained inside the box
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final preset in controller.presets)
                          _PresetChip(
                            label: preset.name,
                            subLabel: preset.summary,
                            isSelected: controller.config == preset.config,
                            isCustom: !preset.isDefault,
                            onDelete: !preset.isDefault
                                ? () => controller.removePreset(preset.id)
                                : null,
                            onTap: () =>
                                controller.applyPresetConfig(preset.config),
                          ),
                      ],
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

            // Rest Between Reps (Inter-rep rest / Cluster pause)
            _ConfigCounterCard(
              title: 'REST BETWEEN REPS',
              subtitle: 'Pause interval between single repetitions',
              icon: Icons.pause_circle_outline_rounded,
              valueText: config.repRestTime == 0 ? 'OFF' : '${config.repRestTime}',
              unitText: config.repRestTime == 0 ? '' : 'SECONDS',
              onDecrement: () => controller.updateRepRestTime(-1),
              onIncrement: () => controller.updateRepRestTime(1),
            ),
            const SizedBox(height: 12),

            // Rest Interval Between Sets
            _ConfigCounterCard(
              title: 'REST TIME (SETS)',
              subtitle: 'Recovery period between completed sets',
              icon: Icons.timer_rounded,
              valueText: '${config.restTime}',
              unitText: 'SECONDS',
              onDecrement: () => controller.updateRestTime(-5),
              onIncrement: () => controller.updateRestTime(5),
            ),
            const SizedBox(height: 16),

            // Vibration & Haptic Options Card
            Card(
              color: colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.vibration_rounded,
                          color: colorScheme.onPrimaryContainer,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        'Vibrate Before Each Set',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Haptic alert when entering work phase',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      value: config.vibrateOnSetStart,
                      onChanged: (_) => controller.toggleVibrateOnSetStart(),
                    ),
                    const Divider(height: 10),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: colorScheme.onSecondaryContainer,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        'Vibrate After Completing Set',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Dual-pulse haptic cue upon final rep',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      value: config.vibrateOnSetComplete,
                      onChanged: (_) => controller.toggleVibrateOnSetComplete(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
      },
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final String subLabel;
  final bool isSelected;
  final bool isCustom;
  final VoidCallback? onDelete;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.subLabel,
    required this.isSelected,
    this.isCustom = false,
    this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCustom) ...[
                Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: isSelected ? colorScheme.primary : colorScheme.secondary,
                ),
                const SizedBox(width: 6),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (isCustom && onDelete != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Text(
                          valueText,
                          key: ValueKey<String>(valueText),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        unitText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w700,
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
                minimumSize: const Size(48, 48),
              ),
              child: const Icon(Icons.remove_rounded, size: 22),
            ),
            const SizedBox(width: 6),
            FilledButton.tonal(
              onPressed: onIncrement,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                minimumSize: const Size(48, 48),
              ),
              child: const Icon(Icons.add_rounded, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
