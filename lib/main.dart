import 'package:flutter/material.dart';
import 'controllers/workout_controller.dart';
import 'screens/setup_screen.dart';
import 'screens/workout_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TempoFitApp());
}

class TempoFitApp extends StatefulWidget {
  const TempoFitApp({super.key});

  @override
  State<TempoFitApp> createState() => _TempoFitAppState();
}

class _TempoFitAppState extends State<TempoFitApp> {
  final WorkoutController _controller = WorkoutController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'TempoFit',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: ThemeMode.system,
          home: _controller.state.isRunning
              ? WorkoutScreen(controller: _controller)
              : SetupScreen(controller: _controller),
        );
      },
    );
  }
}
