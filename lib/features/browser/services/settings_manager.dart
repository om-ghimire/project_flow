import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();

  factory SettingsManager() {
    return _instance;
  }

  SettingsManager._internal();

  static const String _keyAdBlockEnabled = 'ad_block_enabled';
  static const String _keyBlockedAdsCount = 'blocked_ads_count';
  static const String _keyAdBlockFilters = 'ad_block_filters';
  static const String _keySelectedDns = 'selected_dns';
  static const String _keyBiometricEnabled = 'biometric_enabled';

  Future<bool> getAdBlockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAdBlockEnabled) ?? false;
  }

  Future<void> setAdBlockEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAdBlockEnabled, value);
  }

  Future<int> getBlockedAdsCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyBlockedAdsCount) ?? 0;
  }

  Future<void> setBlockedAdsCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBlockedAdsCount, count);
  }

  Future<List<String>> getAdBlockFilters() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyAdBlockFilters) ?? [];
  }

  Future<void> setAdBlockFilters(List<String> filters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyAdBlockFilters, filters);
  }

  Future<String?> getSelectedDns() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedDns);
  }

  Future<void> setSelectedDns(String dns) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedDns, dns);
  }

  Future<bool> getBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }
}
