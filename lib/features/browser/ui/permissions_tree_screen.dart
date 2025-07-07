import 'package:flutter/material.dart';
import '../models/site_permission.dart';

class SitePermissionsScreen extends StatefulWidget {
  final List<SitePermission> sitePermissions;

  const SitePermissionsScreen({super.key, required this.sitePermissions});

  @override
  State<SitePermissionsScreen> createState() => _SitePermissionsScreenState();
}

class _SitePermissionsScreenState extends State<SitePermissionsScreen> {
  late List<SitePermission> permissions;

  @override
  void initState() {
    super.initState();
    permissions = widget.sitePermissions;
  }

  void _togglePermission(SitePermission site, String permissionType, bool value) {
    setState(() {
      switch (permissionType) {
        case 'location':
          site.allowLocation = value;
          break;
        case 'camera':
          site.allowCamera = value;
          break;
        case 'microphone':
          site.allowMicrophone = value;
          break;
      }
    });
    // TODO: persist changes (e.g., save to shared prefs)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Site Permissions')),
      body: ListView.builder(
        itemCount: permissions.length,
        itemBuilder: (context, index) {
          final site = permissions[index];
          return ExpansionTile(
            title: Text(site.origin),
            children: [
              SwitchListTile(
                title: const Text('Allow Location'),
                value: site.allowLocation,
                onChanged: (val) => _togglePermission(site, 'location', val),
              ),
              SwitchListTile(
                title: const Text('Allow Camera'),
                value: site.allowCamera,
                onChanged: (val) => _togglePermission(site, 'camera', val),
              ),
              SwitchListTile(
                title: const Text('Allow Microphone'),
                value: site.allowMicrophone,
                onChanged: (val) => _togglePermission(site, 'microphone', val),
              ),
            ],
          );
        },
      ),
    );
  }
}
