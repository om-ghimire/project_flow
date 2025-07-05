import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/tab_models.dart';
import '../widgets/omni_bar.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late InAppWebViewController webViewController;
  bool isWebViewReady = false;
  bool isLoading = false;

  List<BrowserTab> openTabs = [];
  String currentTabId = '';
  String currentUrl = '';

  @override
  void initState() {
    super.initState();
    _createInitialTab();
  }

  void _createInitialTab() {
    final tab = _generateTab('https://google.com', 'Google');
    setState(() {
      openTabs.add(tab);
      currentTabId = tab.id;
      currentUrl = tab.url;
    });
  }

  BrowserTab _generateTab(String url, String title) {
    return BrowserTab(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: url,
      title: title,
      stackId: 'default',
      faviconUrl: _getFaviconUrl(url),
      isRead: false,
    );
  }

  void _openNewTab(String url, String title) {
    final tab = _generateTab(url, title);
    setState(() {
      openTabs.add(tab);
      currentTabId = tab.id;
      currentUrl = tab.url;
    });
    _loadCurrentTabUrl();
  }

  void _closeTab(BrowserTab tab) {
    setState(() {
      openTabs.removeWhere((t) => t.id == tab.id);
      if (currentTabId == tab.id) {
        if (openTabs.isNotEmpty) {
          final lastTab = openTabs.last;
          currentTabId = lastTab.id;
          currentUrl = lastTab.url;
        } else {
          _createInitialTab();
        }
      }
    });
  }

  void _onTabSelected(BrowserTab tab) {
    setState(() {
      currentTabId = tab.id;
      currentUrl = tab.url;
    });
    _loadCurrentTabUrl();
  }

  void _loadCurrentTabUrl() {
    final tab = openTabs.firstWhere((t) => t.id == currentTabId, orElse: () => openTabs.first);
    webViewController.loadUrl(urlRequest: URLRequest(url: WebUri(tab.url)));
  }

  Future<void> _loadUrl(String url) async {
    if (!isWebViewReady) return;
    setState(() {
      isLoading = true;
      currentUrl = url;
    });
    webViewController.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  void _onLoadStart(Uri? url) {
    if (url != null) {
      setState(() {
        currentUrl = url.toString();
        isLoading = true;
      });
    }
  }

  void _onLoadStop(Uri? url) {
    setState(() {
      isLoading = false;
    });
    if (url == null || currentTabId.isEmpty) return;

    final index = openTabs.indexWhere((t) => t.id == currentTabId);
    if (index != -1) {
      openTabs[index] = openTabs[index].copyWith(
        url: url.toString(),
        isRead: true,
        faviconUrl: _getFaviconUrl(url.toString()),
      );
      setState(() {
        currentUrl = url.toString();
      });
    }
  }

  String _getFaviconUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.scheme}://${uri.host}/favicon.ico';
    } catch (_) {
      return '';
    }
  }

  void _showTabSwitcher() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: openTabs.length,
                  itemBuilder: (context, index) {
                    final tab = openTabs[index];
                    return ListTile(
                      leading: tab.faviconUrl!.isNotEmpty
                          ? Image.network(tab.faviconUrl!, width: 24, height: 24, errorBuilder: (_, __, ___) => const Icon(Icons.public))
                          : const Icon(Icons.public),
                      title: Text(
                        tab.title.isNotEmpty ? tab.title : tab.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                          _closeTab(tab);
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _onTabSelected(tab);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('New Tab'),
                  onPressed: () {
                    Navigator.pop(context);
                    _openNewTab('https://google.com', 'Google');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = openTabs.firstWhere((tab) => tab.id == currentTabId, orElse: () => openTabs.first);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTab.title.isNotEmpty ? currentTab.title : 'Browser'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tab),
            tooltip: 'Tabs',
            onPressed: _showTabSwitcher,
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onPressed: _showMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          OmniBar(
            initialUrl: currentUrl,
            onGoPressed: (url) {
              final index = openTabs.indexWhere((t) => t.id == currentTabId);
              if (index != -1) {
                openTabs[index] = openTabs[index].copyWith(url: url, isRead: false);
              }
              _loadUrl(url);
            },
          ),
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: InAppWebView(
              key: ValueKey(currentTab.id),
              initialUrlRequest: URLRequest(url: WebUri(currentTab.url)),
              onWebViewCreated: (controller) {
                webViewController = controller;
                isWebViewReady = true;
              },
              onLoadStart: (_, url) => _onLoadStart(url),
              onLoadStop: (_, url) => _onLoadStop(url),
              onProgressChanged: (_, progress) {
                setState(() {
                  isLoading = progress < 100;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
