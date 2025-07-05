import 'package:flutter/material.dart';
import '../models/tab_models.dart';

class BrowserTabBar extends StatelessWidget {
  final List<BrowserTab> tabs;
  final String currentTabId;
  final void Function(BrowserTab tab) onTabSelected;
  final void Function(BrowserTab tab) onTabClosed;
  final VoidCallback onNewTab;
  final void Function(BrowserTab tab)? onTabLongPressed;

  const BrowserTabBar({
    super.key,
    required this.tabs,
    required this.currentTabId,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.onNewTab,
    this.onTabLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isActive = tab.id == currentTabId;
                return _buildTabChip(context, tab, isActive, theme);
              },
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: onNewTab,
            icon: const Icon(Icons.add_rounded),
            label: const Text('New'),
            style: FilledButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(
      BuildContext context,
      BrowserTab tab,
      bool isActive,
      ThemeData theme,
      ) {
    final Color bgColor = isActive
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceVariant;
    final Color textColor = isActive
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => onTabSelected(tab),
      onLongPress: () => onTabLongPressed?.call(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFavicon(tab.faviconUrl),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                tab.title.isNotEmpty ? tab.title : _getDomain(tab.url),
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge!.copyWith(
                  color: textColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => onTabClosed(tab),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close, size: 18, color: textColor.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavicon(String? url) {
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          url,
          width: 20,
          height: 20,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.public_rounded, size: 18, color: Colors.grey),
        ),
      );
    } else {
      return const Icon(Icons.public_rounded, size: 18, color: Colors.grey);
    }
  }

  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.startsWith('www.') ? uri.host.substring(4) : uri.host;
    } catch (_) {
      return url;
    }
  }
}
