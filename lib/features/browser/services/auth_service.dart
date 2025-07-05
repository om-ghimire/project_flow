import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticateUser({String reason = 'Please authenticate'}) async {
    final isAvailable = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();

    if (!isAvailable || !isDeviceSupported) return false;

    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print("Biometric auth error: $e");
      return false;
    }
  }
}
