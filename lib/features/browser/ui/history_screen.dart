import 'package:flutter/material.dart';
import '../services/history_manager.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final loaded = await HistoryManager().getHistory();
    setState(() {
      history = loaded;
    });
  }

  void _clearHistory() async {
    await HistoryManager().clearHistory();
    setState(() {
      history = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Clear History',
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('No browsing history'))
          : ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final entry = history[index];
          return ListTile(
            title: Text(entry.url),
            subtitle: Text(
              entry.visitedAt.toLocal().toString(),
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () {
              // Close history and return URL to open
              Navigator.pop(context, entry.url);
            },
          );
        },
      ),
    );
  }
}
