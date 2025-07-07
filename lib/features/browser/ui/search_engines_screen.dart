import 'package:flutter/material.dart';
import '../services/search_engine_manager.dart';

class SearchEnginesScreen extends StatefulWidget {
  const SearchEnginesScreen({super.key});

  @override
  State<SearchEnginesScreen> createState() => _SearchEnginesScreenState();
}

class _SearchEnginesScreenState extends State<SearchEnginesScreen> {
  List<SearchEngine> engines = [];

  @override
  void initState() {
    super.initState();
    _loadEngines();
  }

  Future<void> _loadEngines() async {
    final list = await SearchEngineManager().getEngines();
    setState(() => engines = list);
  }

  void _addEngine() {
    // Show dialog to add a new engine (name + URL template)
  }

  void _editEngine(SearchEngine engine) {
    // Show dialog to edit selected engine
  }

  void _deleteEngine(SearchEngine engine) async {
    await SearchEngineManager().deleteEngine(engine.id);
    _loadEngines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Engines')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEngine,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: engines.length,
        itemBuilder: (context, index) {
          final engine = engines[index];
          return ListTile(
            title: Text(engine.name),
            subtitle: Text(engine.urlTemplate),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editEngine(engine),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteEngine(engine),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
