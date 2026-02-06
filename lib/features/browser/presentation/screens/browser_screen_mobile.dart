import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../../core/constants/app_constants.dart';

/// Mobile browser view using InAppWebView
class MobileBrowserView extends StatefulWidget {
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
  State<MobileBrowserView> createState() => _MobileBrowserViewState();
}

class _MobileBrowserViewState extends State<MobileBrowserView> {
  InAppWebViewController? _webViewController;
  final GlobalKey _webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final initialUrl = widget.initialUrl.isNotEmpty
        ? widget.initialUrl
        : AppConstants.defaultHomePage;

    return InAppWebView(
      key: _webViewKey,
      initialUrlRequest: URLRequest(url: WebUri(initialUrl)),
      initialSettings: InAppWebViewSettings(
        // Android settings
        useHybridComposition: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,

        // iOS settings
        allowsInlineMediaPlayback: true,

        // General settings
        javaScriptEnabled: true,
        supportZoom: true,
        builtInZoomControls: true,
        displayZoomControls: false,
        domStorageEnabled: true,
        databaseEnabled: true,
        transparentBackground: false,

        // File upload settings
        allowFileAccess: true,
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      onLoadStart: (controller, url) {
        widget.onLoadStart?.call();
        if (url != null) {
          widget.onUrlChanged?.call(url.toString());
        }
      },
      onLoadStop: (controller, url) async {
        widget.onLoadStop?.call();
        if (url != null) {
          widget.onUrlChanged?.call(url.toString());
        }
      },
      onProgressChanged: (controller, progress) {
        widget.onProgressChanged?.call(progress / 100);
      },
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint('Console: ${consoleMessage.message}');
      },
      onDownloadStartRequest: (controller, downloadRequest) async {
        debugPrint('Download requested: ${downloadRequest.url}');
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url;

        if (url != null) {
          final scheme = url.scheme;

          // Handle special schemes
          if (scheme != 'http' && scheme != 'https') {
            return NavigationActionPolicy.CANCEL;
          }
        }

        return NavigationActionPolicy.ALLOW;
      },
      onReceivedError: (controller, request, error) {
        debugPrint('WebView error: ${error.description}');
      },
    );
  }
}
