import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  /// Request essential permissions (location, camera, microphone).
  Future<Map<Permission, PermissionStatus>> requestEssentialPermissions() async {
    final statuses = await [
      Permission.location,
      Permission.camera,
      Permission.microphone,
    ].request();
    return statuses;
  }

  /// Get current statuses for essential permissions.
  Future<Map<Permission, PermissionStatus>> getPermissionStatuses() async {
    return {
      Permission.location: await Permission.location.status,
      Permission.camera: await Permission.camera.status,
      Permission.microphone: await Permission.microphone.status,
    };
  }

  /// Opens the app settings screen.
  Future<bool> openAppSettingsScreen() async {
    return await openAppSettings();
  }

  /// Request a specific permission.
  Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status;
  }
}
