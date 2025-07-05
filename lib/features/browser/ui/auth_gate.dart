import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/settings_manager.dart';
import 'browser_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _biometricEnabled = false;
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricAndAuthenticate();
  }

  Future<void> _checkBiometricAndAuthenticate() async {
    final enabled = await SettingsManager().getBiometricEnabled();

    if (!enabled) {
      setState(() {
        _biometricEnabled = false;
        _isAuthenticated = true; // no biometric required
        _checkingAuth = false;
      });
      return;
    }

    setState(() {
      _biometricEnabled = true;
    });

    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      setState(() {
        _isAuthenticated = didAuthenticate;
        _checkingAuth = false;
      });
    } catch (e) {
      // Handle auth errors here if needed
      setState(() {
        _isAuthenticated = false;
        _checkingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: _checkBiometricAndAuthenticate,
            child: const Text('Try Authenticate Again'),
          ),
        ),
      );
    }

    // Authenticated or biometric disabled => show main app screen
    return const BrowserScreen();
  }
}
