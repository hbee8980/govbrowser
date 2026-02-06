import 'package:flutter/material.dart';

/// Web platform stub - InAppWebView not supported on web
/// This file is used when compiling for web
class MobileBrowserView extends StatelessWidget {
  final String initialUrl;
  final Function(String)? onUrlChanged;
  final VoidCallback? onLoadStart;
  final VoidCallback? onLoadStop;
  final Function(double)? onProgressChanged;

  const MobileBrowserView({
    super.key,
    required this.initialUrl,
    this.onUrlChanged,
    this.onLoadStart,
    this.onLoadStop,
    this.onProgressChanged,
  });

  @override
  Widget build(BuildContext context) {
    // This is a stub - on web, we use the _WebBrowserFallback in browser_screen.dart
    return const Center(child: Text('Browser not available on web platform'));
  }
}
