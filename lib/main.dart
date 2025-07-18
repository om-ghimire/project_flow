import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'features/browser/ui/auth_gate.dart';
import 'features/browser/ui/history_screen.dart';
import 'features/browser/ui/search_engines_screen.dart';
import 'features/browser/ui/settings_screen.dart';
import 'features/browser/ui/permissions_screen.dart';

import 'features/browser/services/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  final savedTheme = prefs.getString('themeMode') ?? 'system';
  final themeMode = ThemeManager.stringToThemeMode(savedTheme);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeManager(themeMode),
      child: ProjectFlowApp(showPermissionsFirst: isFirstLaunch),
    ),
  );

  if (isFirstLaunch) {
    await prefs.setBool('isFirstLaunch', false);
  }
}

class ProjectFlowApp extends StatelessWidget {
  final bool showPermissionsFirst;
  const ProjectFlowApp({super.key, required this.showPermissionsFirst});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return MaterialApp(
      title: 'Project Flow',
      debugShowCheckedModeBanner: false,
      themeMode: themeManager.themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: PermissionCheckWrapper(showPermissionsFirst: showPermissionsFirst),
      routes: {
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/permissions': (context) => const PermissionsScreen(),
        '/search_engines': (context) => const SearchEnginesScreen(),
      },
    );
  }
}

class PermissionCheckWrapper extends StatefulWidget {
  final bool showPermissionsFirst;
  const PermissionCheckWrapper({super.key, required this.showPermissionsFirst});

  @override
  State<PermissionCheckWrapper> createState() => _PermissionCheckWrapperState();
}

class _PermissionCheckWrapperState extends State<PermissionCheckWrapper> {
  bool? _showPermissionScreen;

  @override
  void initState() {
    super.initState();
    _checkInitialPermissionState();
  }

  Future<void> _checkInitialPermissionState() async {
    final permissions = [
      Permission.location,
      Permission.camera,
      Permission.microphone,
    ];

    final statuses = await Future.wait(permissions.map((p) => p.status));
    final anyDenied = statuses.any((status) => !status.isGranted);

    setState(() {
      _showPermissionScreen = widget.showPermissionsFirst || anyDenied;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showPermissionScreen == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _showPermissionScreen!
        ? const PermissionsScreen()
        : const AuthGate();
  }
}
