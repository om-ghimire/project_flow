import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/browser/ui/auth_gate.dart';
import 'features/browser/ui/history_screen.dart';
import 'features/browser/ui/search_engines_screen.dart' show SearchEnginesScreen;
import 'features/browser/ui/settings_screen.dart';
import 'features/browser/ui/permissions_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(ProjectFlowApp(showPermissionsFirst: isFirstLaunch));

  if (isFirstLaunch) {
    await prefs.setBool('isFirstLaunch', false);
  }
}

class ProjectFlowApp extends StatelessWidget {
  final bool showPermissionsFirst;
  const ProjectFlowApp({super.key, required this.showPermissionsFirst});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: PermissionCheckWrapper(
        showPermissionsFirst: showPermissionsFirst,
      ),
      routes: {
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/permissions': (context) => const PermissionsScreen(),
        '/search_engines': (context) => const SearchEnginesScreen(),
      },
    );
  }
}

/// Wrapper widget to check permissions on app resume
class PermissionCheckWrapper extends StatefulWidget {
  final bool showPermissionsFirst;
  const PermissionCheckWrapper({super.key, required this.showPermissionsFirst});

  @override
  State<PermissionCheckWrapper> createState() => _PermissionCheckWrapperState();
}

class _PermissionCheckWrapperState extends State<PermissionCheckWrapper> with WidgetsBindingObserver {
  bool _needsPermissions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionsOnStart();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionsOnStart();
    }
  }

  Future<void> _checkPermissionsOnStart() async {
    final allGranted = await _areAllPermissionsGranted();
    if (!allGranted) {
      setState(() {
        _needsPermissions = true;
      });
    } else {
      setState(() {
        _needsPermissions = false;
      });
    }
  }

  Future<bool> _areAllPermissionsGranted() async {
    final permissions = [
      Permission.location,
      Permission.camera,
      Permission.microphone,
      // Add other required permissions here
    ];

    for (var permission in permissions) {
      if (!await permission.isGranted) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsPermissions || widget.showPermissionsFirst) {
      return const PermissionsScreen();
    } else {
      return const AuthGate();
    }
  }
}
