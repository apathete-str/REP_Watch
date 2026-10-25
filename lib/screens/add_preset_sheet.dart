import 'package:flutter/material.dart';
import '../models/workout_model.dart';

/// Modal bottom sheet allowing users to save their current workout
/// configuration as a custom named preset or adjust values and save.
class AddPresetSheet extends StatefulWidget {
  final WorkoutConfig initialConfig;
  final void Function(String name, WorkoutConfig config) onSave;

  const AddPresetSheet({
    super.key,
    required this.initialConfig,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required WorkoutConfig initialConfig,
    required void Function(String name, WorkoutConfig config) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: AddPresetSheet(
          initialConfig: initialConfig,
          onSave: onSave,
        ),
      ),
    );
  }

  @override
  State<AddPresetSheet> createState() => _AddPresetSheetState();
}

class _AddPresetSheetState extends State<AddPresetSheet> {
  late final TextEditingController _nameController;
  late int _sets;
  late int _reps;
  late int _duration;
  late int _repRest;
  late int _rest;
  late bool _vibrateStart;
  late bool _vibrateComplete;

  @override
  void initState() {
    super.initState();
    _sets = widget.initialConfig.sets;
    _reps = widget.initialConfig.reps;
    _duration = widget.initialConfig.repDuration;
    _repRest = widget.initialConfig.repRestTime;
    _rest = widget.initialConfig.restTime;
    _vibrateStart = widget.initialConfig.vibrateOnSetStart;
    _vibrateComplete = widget.initialConfig.vibrateOnSetComplete;
    _nameController = TextEditingController(
      text: 'Preset ${_sets}x$_reps',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final config = WorkoutConfig(
      sets: _sets,
      reps: _reps,
      repDuration: _duration,
      repRestTime: _repRest,
      restTime: _rest,
      prepTime: widget.initialConfig.prepTime,
      vibrateOnSetStart: _vibrateStart,
      vibrateOnSetComplete: _vibrateComplete,
    );
    widget.onSave(name.isEmpty ? 'Custom Preset' : name, config);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.playlist_add_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Save Quick Preset',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Customize & name your routine',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Name field
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Preset Name',
              hintText: 'e.g. Chest Burnout, Fast Arms',
              filled: true,
              fillColor: colorScheme.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.edit_note_rounded),
            ),
          ),
          const SizedBox(height: 18),

          // Adjustable fine-tuning counters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                _MiniRow(
                  label: 'Sets',
                  value: '$_sets',
                  onMinus: () => setState(() => _sets = (_sets - 1).clamp(1, 50)),
                  onPlus: () => setState(() => _sets = (_sets + 1).clamp(1, 50)),
                ),
                const Divider(height: 16),
                _MiniRow(
                  label: 'Reps / Set',
                  value: '$_reps',
                  onMinus: () => setState(() => _reps = (_reps - 1).clamp(1, 100)),
                  onPlus: () => setState(() => _reps = (_reps + 1).clamp(1, 100)),
                ),
                const Divider(height: 16),
                _MiniRow(
                  label: 'Rep Cadence',
                  value: '${_duration}s',
                  onMinus: () =>
                      setState(() => _duration = (_duration - 1).clamp(1, 30)),
                  onPlus: () =>
                      setState(() => _duration = (_duration + 1).clamp(1, 30)),
                ),
                const Divider(height: 16),
                _MiniRow(
                  label: 'Rest Between Reps',
                  value: _repRest == 0 ? 'None' : '${_repRest}s',
                  onMinus: () =>
                      setState(() => _repRest = (_repRest - 1).clamp(0, 30)),
                  onPlus: () =>
                      setState(() => _repRest = (_repRest + 1).clamp(0, 30)),
                ),
                const Divider(height: 16),
                _MiniRow(
                  label: 'Rest Between Sets',
                  value: '${_rest}s',
                  onMinus: () =>
                      setState(() => _rest = (_rest - 5).clamp(5, 600)),
                  onPlus: () =>
                      setState(() => _rest = (_rest + 5).clamp(5, 600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Vibration settings card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.vibration_rounded, color: colorScheme.onPrimaryContainer, size: 20),
                  ),
                  title: const Text('Vibrate Before Set Starts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  value: _vibrateStart,
                  onChanged: (val) => setState(() => _vibrateStart = val),
                ),
                const Divider(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.check_circle_outline_rounded, color: colorScheme.onSecondaryContainer, size: 20),
                  ),
                  title: const Text('Vibrate After Set Completes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  value: _vibrateComplete,
                  onChanged: (val) => setState(() => _vibrateComplete = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.bookmark_add_rounded, size: 22),
            label: const Text(
              'Save Preset',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: const StadiumBorder(),
              elevation: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _MiniRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton.tonal(
          onPressed: onMinus,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            minimumSize: const Size(40, 40),
            padding: EdgeInsets.zero,
          ),
          child: const Icon(Icons.remove_rounded, size: 18),
        ),
        SizedBox(
          width: 58,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
        FilledButton.tonal(
          onPressed: onPlus,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            minimumSize: const Size(40, 40),
            padding: EdgeInsets.zero,
          ),
          child: const Icon(Icons.add_rounded, size: 18),
        ),
      ],
    );
  }
}
