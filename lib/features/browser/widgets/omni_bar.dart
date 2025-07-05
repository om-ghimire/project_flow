import 'package:flutter/material.dart';

class OmniBar extends StatefulWidget {
  final String initialUrl;
  final void Function(String url) onGoPressed;
  final VoidCallback? onTabsPressed;
  final VoidCallback? onMenuPressed;
  final int tabCount; // Added for the tab counter display

  const OmniBar({
    Key? key,
    required this.initialUrl,
    required this.onGoPressed,
    this.onTabsPressed,
    this.onMenuPressed,
    this.tabCount = 0, // Default to 0 if not provided
  }) : super(key: key);

  @override
  State<OmniBar> createState() => _OmniBarState();
}

class _OmniBarState extends State<OmniBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showClearButton = false; // Renamed for clarity

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
    _focusNode = FocusNode();

    // Listen to changes in the text field to show/hide the clear button
    _controller.addListener(_updateClearButtonVisibility);
    // Listen to focus changes for potential UI updates (e.g., border color)
    _focusNode.addListener(_onFocusChange);
    // Set initial clear button state based on initialUrl
    _showClearButton = _controller.text.isNotEmpty;
  }

  void _updateClearButtonVisibility() {
    setState(() {
      _showClearButton = _controller.text.isNotEmpty;
    });
  }

  void _onFocusChange() {
    setState(() {
      // Rebuild to apply focus-related styling if any
    });
  }

  @override
  void didUpdateWidget(covariant OmniBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update text only if URL changed and text field is not currently focused
    if (oldWidget.initialUrl != widget.initialUrl && !_focusNode.hasFocus) {
      _controller.text = widget.initialUrl;
      _showClearButton = _controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateClearButtonVisibility);
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Helper to determine the leading icon based on URL
  IconData _getLeadingIcon(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme == 'https') {
        return Icons.lock_rounded; // Secure connection
      } else if (uri.hasScheme) {
        return Icons.public_rounded; // Other schemes (http, file, etc.)
      }
    } catch (_) {
      // Invalid URL, treat as search
    }
    return Icons.search_rounded; // Default to search icon
  }

  // Helper to format input as URL or search query
  String _formatInputToUrl(String input) {
    input = input.trim();
    if (input.isEmpty) return 'https://www.google.com'; 

    try {
      Uri uri = Uri.parse(input);
      // If it has a scheme (http, https, ftp etc.)
      if (uri.hasScheme) {
        return uri.toString();
      }
      // If it looks like a domain (contains a dot), prepend https
      if (input.contains('.') && !input.contains(' ')) {
        return 'https://$input';
      }
      // Otherwise, assume it's a search query
      return 'https://www.google.com/search?q=${Uri.encodeComponent(input)}';
    } catch (_) {
      // Fallback in case of parsing errors, assume search
      return 'https://www.google.com/search?q=${Uri.encodeComponent(input)}';
    }
  }

  void _onSubmit() {
    final input = _controller.text;
    final url = _formatInputToUrl(input);
    widget.onGoPressed(url);
    _focusNode.unfocus(); // Close keyboard after submission
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colors for the text field container
    final Color omniBarBgColor = _focusNode.hasFocus
        ? (isDark ? Colors.grey[850]! : Colors.blue.shade50) // Lighter blue when focused
        : (isDark ? Colors.grey[900]! : Colors.grey.shade200); // Standard background

    // Color for text and icons inside the omnibar
    final Color omniBarContentColor = _focusNode.hasFocus
        ? theme.colorScheme.onSurface // Brighter when focused
        : theme.colorScheme.onSurfaceVariant; // More subdued when not focused

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8), // Adjusted padding
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer( // Animates background color and border
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: 48, // Slightly taller for better touch target
              decoration: BoxDecoration(
                color: omniBarBgColor,
                borderRadius: BorderRadius.circular(28), // Fully rounded ends
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? theme.colorScheme.primary.withOpacity(0.6) // Primary accent border when focused
                      : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: _focusNode.hasFocus
                    ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
                    : [],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16), // Internal padding
              child: Row(
                children: [
                  // Leading Icon: Search, Lock, or Globe
                  Icon(
                    _getLeadingIcon(widget.initialUrl),
                    size: 20,
                    color: omniBarContentColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.go, // Keyboard "Go" button
                      keyboardType: TextInputType.url, // Hint for URL input
                      style: TextStyle(
                        color: omniBarContentColor,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Search or type URL',
                        hintStyle: TextStyle(color: omniBarContentColor.withOpacity(0.5)),
                      ),
                      onSubmitted: (_) => _onSubmit(),
                    ),
                  ),
                  if (_showClearButton)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        _updateClearButtonVisibility(); // Update state immediately
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0), // Spacing from text field
                        child: Icon(
                          Icons.cancel_rounded, // Rounded cancel icon
                          size: 20,
                          color: omniBarContentColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Tab counter button
          if (widget.onTabsPressed != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0), // Spacing from omnibar
              child: Material( // Use Material for elevation and InkWell ripple
                color: Colors.transparent, // Make Material transparent
                borderRadius: BorderRadius.circular(10), // Match inner button curvature
                clipBehavior: Clip.antiAlias, // Clip inkwell ripple
                child: InkWell(
                  onTap: widget.onTabsPressed,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant, // Themed background
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [ // Subtle shadow to make it pop
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.tabCount.toString(),
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Larger font size for count
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // More options menu button
          if (widget.onMenuPressed != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0), // Spacing
              child: IconButton(
                onPressed: widget.onMenuPressed,
                icon: Icon(
                  Icons.more_vert_rounded, // Rounded menu icon
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                tooltip: 'More options',
              ),
            ),
        ],
      ),
    );
  }
}