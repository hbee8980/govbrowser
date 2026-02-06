import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/url_bar.dart';
import '../widgets/sidekick_overlay.dart';
import '../../providers/browser_provider.dart';
import '../../../../core/constants/app_constants.dart';

// Conditional import for InAppWebView
import 'browser_screen_mobile.dart'
    if (dart.library.html) 'browser_screen_web.dart'
    as platform;

/// The main browser screen with WebView and Sidekick overlay
class BrowserScreen extends ConsumerStatefulWidget {
  final String? initialUrl;

  const BrowserScreen({super.key, this.initialUrl});

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  late String _currentUrl;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl ?? AppConstants.defaultHomePage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(browserProvider.notifier).updateUrl(_currentUrl);
    });
  }

  void _handleUrlSubmit(String url) {
    setState(() => _currentUrl = url);
    ref.read(browserProvider.notifier).updateUrl(url);
  }

  Future<void> _openInExternalBrowser() async {
    final uri = Uri.parse(_currentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content column
            Column(
              children: [
                // URL Bar
                UrlBar(
                  onSubmit: _handleUrlSubmit,
                  onRefresh: () {
                    // Refresh - on web, just reload the iframe
                    setState(() {});
                  },
                ),

                // Loading progress
                const UrlBarProgress(),

                // WebView or Web fallback
                Expanded(
                  child: kIsWeb
                      ? _WebBrowserFallback(
                          url: _currentUrl,
                          onOpenExternal: _openInExternalBrowser,
                        )
                      : platform.MobileBrowserView(
                          initialUrl: _currentUrl,
                          onUrlChanged: (url) {
                            ref.read(browserProvider.notifier).updateUrl(url);
                          },
                          onLoadStart: () {
                            ref.read(browserProvider.notifier).setLoading(true);
                          },
                          onLoadStop: () {
                            ref
                                .read(browserProvider.notifier)
                                .setLoading(false);
                          },
                          onProgressChanged: (progress) {
                            ref
                                .read(browserProvider.notifier)
                                .updateProgress(progress);
                          },
                        ),
                ),
              ],
            ),

            // Sidekick Overlay (on top of everything)
            const SidekickOverlay(),
          ],
        ),
      ),
    );
  }
}

/// Fallback for web platform - shows a preview and link to open externally
class _WebBrowserFallback extends StatelessWidget {
  final String url;
  final VoidCallback onOpenExternal;

  const _WebBrowserFallback({required this.url, required this.onOpenExternal});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.language,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Web Browser Preview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Full browser functionality is available on mobile.\nClick below to open the URL in a new tab.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              url,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onOpenExternal,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in New Tab'),
          ),
          const SizedBox(height: 48),
          // Still show the sidekick info
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.rocket_launch,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap the rocket button to access the Sidekick Panel with your profile data and image tools!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
