import 'package:flutter/material.dart';
import 'features/browser/ui/auth_gate.dart'; // import AuthGate
import 'features/browser/ui/history_screen.dart';
import 'features/browser/ui/settings_screen.dart';

void main() {
  runApp(const ProjectFlowApp());
}

class ProjectFlowApp extends StatelessWidget {
  const ProjectFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const AuthGate(),  // show AuthGate instead of BrowserScreen
      routes: {
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
