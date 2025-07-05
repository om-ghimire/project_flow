import 'package:webview_flutter/webview_flutter.dart';

class BrowserTab {
  final String id;
  final String url;
  final String title;
  final String stackId;
  final bool isRead;
  final String? thumbnailPath;
  final String? faviconUrl;
  WebViewController? controller;  // mutable field

  BrowserTab({
    required this.id,
    required this.url,
    required this.title,
    required this.stackId,
    this.isRead = false,
    this.thumbnailPath,
    this.faviconUrl,
    this.controller,
  });

  BrowserTab copyWith({
    String? id,
    String? url,
    String? title,
    String? stackId,
    bool? isRead,
    String? thumbnailPath,
    String? faviconUrl,
    WebViewController? controller,
  }) {
    return BrowserTab(
      title: title ?? this.title,
      id: id ?? this.id,
      url: url ?? this.url,
      stackId: stackId ?? this.stackId,
      isRead: isRead ?? this.isRead,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      controller: controller ?? this.controller,
    );
  }
}
