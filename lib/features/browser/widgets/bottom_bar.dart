import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final VoidCallback onNewTab;
  final VoidCallback onShowMenu;
  final Widget omniBar;

  const BottomBar({
    Key? key,
    required this.omniBar,
    required this.onNewTab,
    required this.onShowMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(child: omniBar),

            const SizedBox(width: 6),

            // ➕ New Tab Button
            IconButton(
              icon: const Icon(Icons.add, size: 26),
              tooltip: "New Tab",
              onPressed: onNewTab,
            ),

            // ☰ Menu Button
            IconButton(
              icon: const Icon(Icons.menu, size: 26),
              tooltip: "Menu",
              onPressed: onShowMenu,
            ),
          ],
        ),
      ),
    );
  }
}
