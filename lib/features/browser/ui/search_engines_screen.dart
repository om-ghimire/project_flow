import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
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
    _showEngineDialog();
  }

  void _editEngine(SearchEngine engine) {
    _showEngineDialog(existing: engine);
  }

  void _deleteEngine(SearchEngine engine) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Search Engine'),
        content: Text('Are you sure you want to delete "${engine.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await SearchEngineManager().deleteEngine(engine.id);
      _loadEngines();
    }
  }

  void _showEngineDialog({SearchEngine? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final urlController = TextEditingController(text: existing?.urlTemplate ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Add Search Engine' : 'Edit Search Engine'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL Template (use `{query}`)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final url = urlController.text.trim();
              if (name.isEmpty || url.isEmpty || !url.contains('{query}')) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Invalid name or URL (must include {query})'),
                ));
                return;
              }

              final engine = SearchEngine(
                id: existing?.id ?? const Uuid().v4(),
                name: name,
                urlTemplate: url,
              );

              await SearchEngineManager().addOrUpdateEngine(engine);
              _loadEngines();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Engines')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEngine,
        tooltip: 'Add Engine',
        child: const Icon(Icons.add),
      ),
      body: engines.isEmpty
          ? const Center(child: Text('No search engines added.'))
          : ListView.builder(
        itemCount: engines.length,
        itemBuilder: (context, index) {
          final engine = engines[index];
          return ListTile(
            title: Text(engine.name),
            subtitle: Text(engine.urlTemplate),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _editEngine(engine)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteEngine(engine)),
              ],
            ),
          );
        },
      ),
    );
  }
}
