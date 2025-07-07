import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchEngine {
  final String id;
  final String name;
  final String urlTemplate;

  SearchEngine({required this.id, required this.name, required this.urlTemplate});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'urlTemplate': urlTemplate};
  static SearchEngine fromJson(Map<String, dynamic> json) => SearchEngine(
      id: json['id'], name: json['name'], urlTemplate: json['urlTemplate']);
}

class SearchEngineManager {
  static final SearchEngineManager _instance = SearchEngineManager._internal();
  factory SearchEngineManager() => _instance;
  SearchEngineManager._internal();

  static const _enginesKey = 'search_engines';

  Future<List<SearchEngine>> getEngines() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_enginesKey) ?? [];
    return jsonList
        .map((e) => SearchEngine.fromJson(json.decode(e)))
        .toList();
  }

  Future<void> addOrUpdateEngine(SearchEngine engine) async {
    final prefs = await SharedPreferences.getInstance();
    final engines = await getEngines();
    final idx = engines.indexWhere((e) => e.id == engine.id);
    if (idx == -1) {
      engines.add(engine);
    } else {
      engines[idx] = engine;
    }
    final jsonList = engines.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_enginesKey, jsonList);
  }

  Future<void> deleteEngine(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final engines = await getEngines();
    engines.removeWhere((e) => e.id == id);
    final jsonList = engines.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_enginesKey, jsonList);
  }
}
