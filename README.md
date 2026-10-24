# TempoFit - Flutter Material 3 App

A workout repetition and cadence tracker built with **Flutter** and **Material Design 3 (Material You)**.

## Features
- **Material 3 Design**:
  - Full Material 3 tonal palettes with `ColorScheme.fromSeed` and dynamic light & dark theme support.
  - Expressive chips (`FilterChip`), segmented cards, elevated stadium buttons, and circular status rings.
- **Configurable Routine**:
  - Sets, reps per set, rep cadence (seconds per rep), and rest intervals (seconds).
  - Quick presets: Hypertrophy (3x10 @ 4s), Strength (5x5 @ 5s), Endurance (4x15 @ 3s), Speed / Power (4x6 @ 2s).
- **Synchronized Cadence Counter**:
  - Live animated circular ring tracking phase completion.
  - Interactive rhythm cadence bar showing rep progress within each cadence interval.
- **Auto-Rest Recovery & Audio / Haptic Feedback**:
  - Seamlessly switches to the recovery rest timer.
  - Provides native haptic feedback (`HapticFeedback.lightImpact`, `heavyImpact`) and system cues on rep change and rest countdown (3-2-1).
- **Workout Summary**:
  - Material 3 completion dialog with total sets, reps completed, and overall workout duration.

## Project Structure
```
REP_Watch/
├── lib/
│   ├── main.dart                          # App entry point with reactive theme & controller binding
│   ├── controllers/
│   │   └── workout_controller.dart        # Timer engine, state machine, and haptic feedback
│   ├── models/
│   │   └── workout_model.dart             # WorkoutPhase, WorkoutConfig, and WorkoutState models
│   ├── screens/
│   │   ├── setup_screen.dart              # Material 3 setup panel with stepper controls & preset chips
│   │   ├── workout_screen.dart            # Material 3 circular countdown, cadence bar & dock controls
│   │   └── summary_modal.dart             # Workout completion dialog
│   └── theme/
│       └── app_theme.dart                 # Material 3 light/dark theme definitions & tokens
├── pubspec.yaml                           # Flutter dependencies and configuration
└── .gitignore                             # Standard Flutter / Dart ignore rules
```

## How to Run
1. Fetch dependencies:
   ```bash
   flutter pub get
   ```
2. Run on your connected device or emulator:
   ```bash
   flutter run
   ```
