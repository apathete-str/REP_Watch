# TempoFit - Android Mobile App (Jetpack Compose & Material 3)

A native Android workout repetition and cadence tracker built with **Modern Jetpack Compose** and **Material Design 3 (Material You)**.

## Features
- **Configurable Routine**: Configure sets, reps per set, rep cadence (e.g. 4 seconds per rep), and rest intervals (e.g. 90 seconds).
- **Synchronized Cadence Counter**: Counts up cleanly from 0s, updating every 4 seconds to the next rep (Rep 1, Rep 2, ... Rep 10) with an interactive rhythm progress bar.
- **Auto-Rest Recovery Timer**: Seamlessly transitions to the 90s rest interval upon set completion with warning ticks before the next set begins.
- **Full Fluid Material 3 Experience**:
  - Dynamic Color scheme with light/dark theme support.
  - Floating action buttons, tonal cards, assist chips, and circular progress rings.
  - Edge-to-edge layout with full support for Android gesture navigation.
  - Haptic feedback and native tone synthesis using Android `Vibrator` and `ToneGenerator`.
  - Screen wake-lock (`FLAG_KEEP_SCREEN_ON`) so your phone screen never turns off mid-workout.

## Project Structure
```
android_app/
├── app/
│   ├── src/main/
│   │   ├── AndroidManifest.xml
│   │   ├── java/com/example/tempofit/
│   │   │   ├── MainActivity.kt           # Entry activity with edge-to-edge Compose container
│   │   │   ├── WorkoutModel.kt           # Data classes and WorkoutPhase state machine
│   │   │   ├── WorkoutViewModel.kt       # Coroutine-powered timer and cadence engine
│   │   │   ├── SoundAndHaptics.kt        # Native tone synthesis & vibration engine
│   │   │   ├── ui/
│   │   │   │   ├── SetupScreen.kt        # Material 3 setup panel with stepper controls & chips
│   │   │   │   ├── WorkoutScreen.kt      # Material 3 circular countdown, cadence bar & dock controls
│   │   │   │   └── SummaryModal.kt       # Workout completion dialog
│   │   │   └── ui/theme/
│   │   │       ├── Color.kt              # Material 3 color definitions & workout accents
│   │   │       └── Theme.kt              # Dynamic dark/light color scheme
│   │   └── res/
│   └── build.gradle.kts
├── gradle/
│   ├── libs.versions.toml                # Version catalog for AGP, Kotlin & Compose
│   └── wrapper/
├── build.gradle.kts
└── settings.gradle.kts
```

## How to Open and Run in Android Studio
1. Open **Android Studio** (Hedgehog, Iguana, or Koala+).
2. Click **Open** and select the [`android_app`](file:///home/ansr/Workout_tracker/REP_Watch/android_app) folder.
3. Allow Gradle to sync dependencies.
4. Connect an Android phone (with USB debugging enabled) or launch an Android emulator.
5. Click **Run** (`Shift + F10`) to build and deploy the native app directly to your phone.

