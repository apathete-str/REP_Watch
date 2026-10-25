import 'package:flutter/material.dart';

import 'controllers/workout_controller.dart';
import 'screens/setup_screen.dart';
import 'screens/workout_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RepWatchApp());
}

class RepWatchApp extends StatefulWidget {
  const RepWatchApp({super.key});

  @override
  State<RepWatchApp> createState() => _RepWatchAppState();
}

class _RepWatchAppState extends State<RepWatchApp> {
  final WorkoutController _controller = WorkoutController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rep Watch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: _AppHome(controller: _controller),
    );
  }
}

class _AppHome extends StatefulWidget {
  final WorkoutController controller;

  const _AppHome({required this.controller});

  @override
  State<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<_AppHome> {
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _isRunning = widget.controller.state.isRunning;
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final running = widget.controller.state.isRunning;
    if (running != _isRunning) {
      setState(() {
        _isRunning = running;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isRunning
        ? WorkoutScreen(controller: widget.controller)
        : SetupScreen(controller: widget.controller);
  }
}
