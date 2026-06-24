import 'package:flutter/material.dart';

import 'app_state.dart';
import 'theme/app_theme.dart';
import 'ui/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settings.load();
  await catalog.load();
  runApp(const ReelPlannerApp());
}

class ReelPlannerApp extends StatelessWidget {
  const ReelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild on settings change (unit system) so the whole tree reformats.
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Reel Capacity Planner',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: const HomeScreen(),
        );
      },
    );
  }
}
