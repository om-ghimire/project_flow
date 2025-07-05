import 'package:flutter/material.dart';

class OmniBar extends StatefulWidget {
  final String initialUrl;
  final void Function(String url) onGoPressed;
  final VoidCallback? onTabsPressed;
  final VoidCallback? onMenuPressed;
  final int tabCount;
  final bool isLoading; // New: to show loading/stop icon

  const OmniBar({
    Key? key,
    required this.initialUrl,
    required this.onGoPressed,
    this.onTabsPressed,
    this.onMenuPressed,
    this.tabCount = 0,
    this.isLoading = false, // Default to not loading
  }) : super(key: key);

  @override
  State<OmniBar> createState() => _OmniBarState();
}

class _OmniBarState extends State<OmniBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    // Initialize controller text: show empty for default Google, otherwise the URL
    _controller = TextEditingController(
        text: _isDefaultGoogleUrl(widget.initialUrl) ? '' : _formatDisplayUrl(widget.initialUrl));
    _focusNode = FocusNode();

    _controller.addListener(_updateClearButtonVisibility);
    _focusNode.addListener(_onFocusChange);
    _showClearButton = _controller.text.isNotEmpty;
  }

  void _updateClearButtonVisibility() {
    setState(() {
      _showClearButton = _controller.text.isNotEmpty;
    });
  }

  void _onFocusChange() {
    setState(() {
      // Rebuild to apply focus-related styling
      // When focused, show full URL if not default Google and input is currently empty
      if (_focusNode.hasFocus && _controller.text.isEmpty && !_isDefaultGoogleUrl(widget.initialUrl)) {
        _controller.text = _formatDisplayUrl(widget.initialUrl);
      } else if (!_focusNode.hasFocus && _isDefaultGoogleUrl(widget.initialUrl)) {
        // If unfocused and it's Google, clear the text to show hint
        _controller.text = '';
      }
    });
  }

  @override
  void didUpdateWidget(covariant OmniBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update text only if URL changed and text field is not currently focused
    if (oldWidget.initialUrl != widget.initialUrl && !_focusNode.hasFocus) {
      _controller.text = _isDefaultGoogleUrl(widget.initialUrl) ? '' : _formatDisplayUrl(widget.initialUrl);
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

  // Helper to determine if the URL is the default Google homepage
  bool _isDefaultGoogleUrl(String url) {
    return url == 'https://www.google.com/' || url == 'https://www.google.com';
  }

  // Helper to format URL for display (e.g., remove 'https://www.')
  String _formatDisplayUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.startsWith('www.')) {
        return uri.host.substring(4) + uri.path; // Remove 'www.'
      }
      return uri.host + uri.path;
    } catch (_) {
      return url; // Return as is if parsing fails
    }
  }

  // Helper to determine the leading icon based on URL and focus state
  IconData _getLeadingIcon(String url) {
    // If focused, and it's a valid URL, show lock/globe. Otherwise, search.
    if (_focusNode.hasFocus) {
      try {
        final uri = Uri.parse(url);
        if (uri.hasScheme) {
          return uri.scheme == 'https' ? Icons.lock_rounded : Icons.public_rounded;
        }
      } catch (_) {
        // Invalid URL, remain search icon
      }
      return Icons.search_rounded; // Default to search when focused or invalid
    } else {
      // When not focused: if it's default Google, show search. Otherwise, lock/globe based on URL.
      if (_isDefaultGoogleUrl(url) || _controller.text.isEmpty) {
        return Icons.search_rounded;
      }
      try {
        final uri = Uri.parse(url);
        if (uri.scheme == 'https') {
          return Icons.lock_rounded;
        } else if (uri.hasScheme) {
          return Icons.public_rounded;
        }
      } catch (_) {
        // Fallback for invalid URLs when not focused
      }
      return Icons.search_rounded;
    }
  }


  // Helper to format input as URL or search query
  String _formatInputToUrl(String input) {
    input = input.trim();
    if (input.isEmpty) return 'https://www.google.com';

    try {
      Uri uri = Uri.parse(input);
      if (uri.hasScheme) {
        return uri.toString();
      }
      if (input.contains('.') && !input.contains(' ')) {
        return 'https://$input';
      }
      return 'https://www.google.com/search?q=${Uri.encodeComponent(input)}';
    } catch (_) {
      return 'https://www.google.com/search?q=${Uri.encodeComponent(input)}';
    }
  }

  void _onSubmit() {
    final input = _controller.text;
    final url = _formatInputToUrl(input);
    widget.onGoPressed(url);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color omniBarBgColor = _focusNode.hasFocus
        ? (isDark ? Colors.grey[850]! : Colors.blue.shade50)
        : (isDark ? Colors.grey[900]! : Colors.grey.shade200);

    final Color omniBarContentColor = theme.colorScheme.onSurface; // Use primary text color consistently

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: 48,
              decoration: BoxDecoration(
                color: omniBarBgColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? theme.colorScheme.primary.withOpacity(0.6)
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
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
                      textInputAction: TextInputAction.go,
                      keyboardType: TextInputType.url,
                      style: TextStyle(
                        color: omniBarContentColor,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Search or type URL',
                        hintStyle: TextStyle(color: omniBarContentColor.withOpacity(0.5)),
                      ),
                      onSubmitted: (_) => _onSubmit(),
                      // On tap, if it's the default Google URL, clear the text
                      onTap: () {
                        if (_isDefaultGoogleUrl(widget.initialUrl) && _controller.text.isEmpty) {
                          _controller.text = ''; // Ensure hint disappears on tap
                        }
                      },
                    ),
                  ),
                  if (_showClearButton)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        _updateClearButtonVisibility();
                        _focusNode.requestFocus(); // Keep focus after clearing
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.cancel_rounded,
                          size: 20,
                          color: omniBarContentColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  // New: Loading/Stop button
                  if (widget.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded), // Stop icon
                        iconSize: 20,
                        color: omniBarContentColor.withOpacity(0.6),
                        onPressed: () {
                          // Handle stop loading action
                          print('Stop loading pressed');
                        },
                        tooltip: 'Stop loading',
                      ),
                    )
                  else if (!_showClearButton && !_isDefaultGoogleUrl(widget.initialUrl) && !_focusNode.hasFocus)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.refresh_rounded), // Refresh icon
                        iconSize: 20,
                        color: omniBarContentColor.withOpacity(0.6),
                        onPressed: () {
                          // Handle refresh action
                          print('Refresh pressed');
                          widget.onGoPressed(widget.initialUrl); // Re-load current URL
                        },
                        tooltip: 'Refresh',
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (widget.onTabsPressed != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: InkWell(
                onTap: widget.onTabsPressed,
                borderRadius: BorderRadius.circular(10), // Increased radius for softer look
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Adjusted padding
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
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
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (widget.onMenuPressed != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: IconButton(
                onPressed: widget.onMenuPressed,
                icon: Icon(
                  Icons.more_vert_rounded,
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