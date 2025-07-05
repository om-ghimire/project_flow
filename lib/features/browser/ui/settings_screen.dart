import 'package:flutter/material.dart';
import '../services/settings_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool adBlockEnabled = false;
  bool biometricEnabled = false;
  int blockedAdsCount = 0;
  List<String> adBlockFilters = [];
  String selectedDns = '1.1.1.1';

  final TextEditingController _filterController = TextEditingController();

  final List<String> dnsOptions = [
    '1.1.1.1',
    '8.8.8.8',
    '9.9.9.9',
    '114.114.114.114',
  ];

  bool _dnsExpanded = false;
  bool _filtersExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    adBlockEnabled = await SettingsManager().getAdBlockEnabled();
    biometricEnabled = await SettingsManager().getBiometricEnabled();
    blockedAdsCount = await SettingsManager().getBlockedAdsCount();
    adBlockFilters = await SettingsManager().getAdBlockFilters();
    selectedDns = await SettingsManager().getSelectedDns() ?? dnsOptions[0];
    setState(() {});
  }

  Future<void> _onAdBlockToggle(bool value) async {
    await SettingsManager().setAdBlockEnabled(value);
    setState(() => adBlockEnabled = value);
  }

  Future<void> _onBiometricToggle(bool value) async {
    await SettingsManager().setBiometricEnabled(value);
    setState(() => biometricEnabled = value);
  }

  Future<void> _addFilter() async {
    final text = _filterController.text.trim();
    if (text.isEmpty) return;
    if (!adBlockFilters.contains(text)) {
      adBlockFilters.add(text);
      await SettingsManager().setAdBlockFilters(adBlockFilters);
      _filterController.clear();
      setState(() {});
    }
  }

  Future<void> _removeFilter(String filter) async {
    adBlockFilters.remove(filter);
    await SettingsManager().setAdBlockFilters(adBlockFilters);
    setState(() {});
  }

  Future<void> _selectDns(String dns) async {
    selectedDns = dns;
    await SettingsManager().setSelectedDns(dns);
    setState(() {});
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile.adaptive(
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildExpansionCard({
    required String title,
    required Widget child,
    required bool initiallyExpanded,
    required ValueChanged<bool> onExpansionChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        initiallyExpanded: initiallyExpanded,
        onExpansionChanged: onExpansionChanged,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [child],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        surfaceTintColor: theme.colorScheme.surfaceTint,
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _buildSwitchTile(
            icon: Icons.block,
            title: 'Enable AdBlocker',
            subtitle: 'Block unwanted ads and trackers',
            value: adBlockEnabled,
            onChanged: _onAdBlockToggle,
          ),

          Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.analytics, color: theme.colorScheme.primary),
              title: Text('Blocked Ads Count', style: theme.textTheme.titleMedium),
              trailing: Text('$blockedAdsCount', style: theme.textTheme.titleLarge),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ),

          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: 'Enable Biometric Authentication',
            subtitle: 'Secure your app with biometrics',
            value: biometricEnabled,
            onChanged: _onBiometricToggle,
          ),

          _buildExpansionCard(
            title: 'Select DNS Provider',
            initiallyExpanded: _dnsExpanded,
            onExpansionChanged: (expanded) => setState(() => _dnsExpanded = expanded),
            child: Column(
              children: dnsOptions.map((dns) {
                return RadioListTile<String>(
                  value: dns,
                  groupValue: selectedDns,
                  title: Text(dns, style: theme.textTheme.bodyLarge),
                  onChanged: (value) {
                    if (value != null) _selectDns(value);
                  },
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ),

          _buildExpansionCard(
            title: 'Custom AdBlock Filters',
            initiallyExpanded: _filtersExpanded,
            onExpansionChanged: (expanded) => setState(() => _filtersExpanded = expanded),
            child: Column(
              children: [
                ...adBlockFilters.map((filter) => ListTile(
                  title: Text(filter, style: theme.textTheme.bodyLarge),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _removeFilter(filter),
                  ),
                  contentPadding: EdgeInsets.zero,
                )),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _filterController,
                        decoration: InputDecoration(
                          labelText: 'Add filter (e.g., ads.example.com)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _addFilter,
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
