import 'dart:io';
import 'package:flutter/material.dart';
import '../models/tab_models.dart';

class TabStackView extends StatelessWidget {
  final List<BrowserTab> tabs;
  final String currentTabId;
  final void Function(BrowserTab) onTabSelected;
  final void Function(BrowserTab)? onTabClosed;

  const TabStackView({
    super.key,
    required this.tabs,
    required this.currentTabId,
    required this.onTabSelected,
    this.onTabClosed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      height: 220,
      padding: const EdgeInsets.all(12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: tabs.map((tab) => _buildTabCard(context, tab)).toList(),
      ),
    );
  }

  Widget _buildTabCard(BuildContext context, BrowserTab tab) {
    bool isActive = tab.id == currentTabId;

    return GestureDetector(
      onTap: () => onTabSelected(tab),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: isActive ? Border.all(color: Colors.blueAccent, width: 2) : null,
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[850],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tab.thumbnailPath != null
                    ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.file(
                    File(tab.thumbnailPath!),
                    height: 100,
                    width: 140,
                    fit: BoxFit.cover,
                  ),
                )
                    : Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Center(child: Icon(Icons.web, size: 50, color: Colors.white30)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      if (tab.faviconUrl != null && tab.faviconUrl!.isNotEmpty)
                        Image.network(
                          tab.faviconUrl!,
                          width: 16,
                          height: 16,
                          errorBuilder: (_, __, ___) => const Icon(Icons.public, size: 16),
                        ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tab.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!tab.isRead)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => onTabClosed?.call(tab),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
