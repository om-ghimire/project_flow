import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_manager.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final PermissionManager permissionManager = PermissionManager();

  Map<Permission, PermissionStatus> statuses = {};

  @override
  void initState() {
    super.initState();
    _loadPermissionsStatus();
  }

  Future<void> _loadPermissionsStatus() async {
    final newStatuses = await permissionManager.getPermissionStatuses();
    setState(() {
      statuses = newStatuses;
    });
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permissionManager.requestPermission(permission);
    setState(() {
      statuses[permission] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissionsToCheck = [
      Permission.location,
      Permission.camera,
      Permission.microphone,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: ListView(
        children: permissionsToCheck.map((permission) {
          final status = statuses[permission] ?? PermissionStatus.denied;

          String statusText;
          switch (status) {
            case PermissionStatus.granted:
              statusText = 'Granted';
              break;
            case PermissionStatus.denied:
              statusText = 'Denied';
              break;
            case PermissionStatus.permanentlyDenied:
              statusText = 'Permanently Denied';
              break;
            case PermissionStatus.restricted:
              statusText = 'Restricted';
              break;
            case PermissionStatus.limited:
              statusText = 'Limited';
              break;
            default:
              statusText = 'Unknown';
          }

          return ListTile(
            title: Text(permission.toString().split('.').last),
            subtitle: Text(statusText),
            trailing: ElevatedButton(
              onPressed: status == PermissionStatus.granted
                  ? null
                  : () => _requestPermission(permission),
              child: Text(status == PermissionStatus.granted ? 'Granted' : 'Request'),
            ),
          );
        }).toList(),
      ),
    );
  }
}
