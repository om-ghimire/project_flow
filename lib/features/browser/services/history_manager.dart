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
    return stored.map((e) => HistoryEntry.fromJson(Map<String, dynamic>.from(
        e.isNotEmpty ? Map<String, dynamic>.from(Uri.splitQueryString(e)) : {}))).toList();
  }

  Future<void> addEntry(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_historyKey) ?? [];

    // Add new entry as query string to avoid JSON parsing complexity:
    final newEntry = Uri(queryParameters: {
      'url': url,
      'visitedAt': DateTime.now().toIso8601String(),
    }).query;

    stored.insert(0, newEntry); // Newest at start
    await prefs.setStringList(_historyKey, stored);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
