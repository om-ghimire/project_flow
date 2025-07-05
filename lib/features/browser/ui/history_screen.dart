import 'package:flutter/material.dart';
import '../services/history_manager.dart';
import 'package:timeago/timeago.dart' as timeago;

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

  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.startsWith('www.') ? uri.host.substring(4) : uri.host;
    } catch (_) {
      return url;
    }
  }

  Widget _buildFavicon(String url) {
    try {
      final uri = Uri.parse(url);
      final faviconUrl = '${uri.scheme}://${uri.host}/favicon.ico';
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          faviconUrl,
          width: 24,
          height: 24,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.public_rounded, size: 24, color: Colors.grey),
        ),
      );
    } catch (_) {
      return const Icon(Icons.public_rounded, size: 24, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear History',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear all history?'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _clearHistory();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('No browsing history'))
          : ListView.separated(
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final entry = history[index];
          final domain = _getDomain(entry.url);
          final timeAgo = timeago.format(entry.visitedAt);
          return Dismissible(
            key: ValueKey(entry.visitedAt.toIso8601String() + entry.url),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete_forever, color: Colors.white),
            ),
            onDismissed: (_) async {
              // Remove dismissed entry from history list and prefs
              history.removeAt(index);
              await HistoryManager().clearHistory();
              for (var e in history) {
                await HistoryManager().addEntry(e.url);
              }
              setState(() {});
            },
            child: ListTile(
              leading: _buildFavicon(entry.url),
              title: Text(domain,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              subtitle: Text(timeAgo),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () {
                  Navigator.pop(context, entry.url);
                },
              ),
              onTap: () {
                Navigator.pop(context, entry.url);
              },
            ),
          );
        },
      ),
    );
  }
}
