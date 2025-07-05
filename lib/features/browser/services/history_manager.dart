import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryEntry {
  final String url;
  final DateTime visitedAt;

  HistoryEntry({required this.url, required this.visitedAt});

  Map<String, dynamic> toJson() => {
    'url': url,
    'visitedAt': visitedAt.toIso8601String(),
  };

  static HistoryEntry fromJson(Map<String, dynamic> json) => HistoryEntry(
    url: json['url'],
    visitedAt: DateTime.parse(json['visitedAt']),
  );
}

class HistoryManager {
  static final HistoryManager _instance = HistoryManager._internal();
  factory HistoryManager() => _instance;
  HistoryManager._internal();

  static const String _historyKey = 'browsing_history';

  Future<List<HistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList(_historyKey);
    if (stored == null) return [];
    return stored
        .map((e) => HistoryEntry.fromJson(json.decode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addEntry(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_historyKey) ?? [];

    final newEntry = HistoryEntry(url: url, visitedAt: DateTime.now());

    // Avoid duplicates: remove any existing entry for this URL
    stored.removeWhere((e) {
      final entry = HistoryEntry.fromJson(json.decode(e));
      return entry.url == url;
    });

    stored.insert(0, json.encode(newEntry.toJson())); // newest first
    await prefs.setStringList(_historyKey, stored);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
