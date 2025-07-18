import 'package:flutter/material.dart';
import 'package:project_flow/features/browser/services/history_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('themeMode') ?? 'system';
    setState(() {
      _themeMode = _parseThemeMode(mode);
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeModeToString(mode));
    setState(() {
      _themeMode = mode;
    });
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          /// Search Engines
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Manage Search Engines'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/search_engines'),
          ),

          /// Permissions
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Manage Permissions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/permissions'),
          ),

          /// Theme
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Text('Theme', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            value: ThemeMode.system,
            groupValue: _themeMode,
            onChanged: (value) => _setThemeMode(value!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: _themeMode,
            onChanged: (value) => _setThemeMode(value!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: _themeMode,
            onChanged: (value) => _setThemeMode(value!),
          ),

          /// Clear Data
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Text('Privacy & Data', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Clear History'),
            onTap: () {
              // implement in history manager
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirm'),
                  content: const Text('Clear browsing history?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () async {
                        await HistoryManager().clearHistory();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History cleared')));
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),

          /// Footer
          const SizedBox(height: 20),
          Center(
            child: Text('Version 1.0.0', style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
