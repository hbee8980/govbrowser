import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../providers/browser_provider.dart';

/// URL bar widget for the browser
class UrlBar extends ConsumerStatefulWidget {
  final bool readOnly;
  final VoidCallback? onRefresh;
  final Function(String)? onSubmit;

  const UrlBar({
    super.key,
    this.readOnly = false,
    this.onRefresh,
    this.onSubmit,
  });

  @override
  ConsumerState<UrlBar> createState() => _UrlBarState();
}

class _UrlBarState extends ConsumerState<UrlBar> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitUrl() {
    final url = _controller.text.trim();
    if (url.isNotEmpty) {
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        formattedUrl = 'https://$url';
      }
      widget.onSubmit?.call(formattedUrl);
      ref.read(browserProvider.notifier).updateUrl(formattedUrl);
      setState(() => _isEditing = false);
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final browserState = ref.watch(browserProvider);

    // Update controller text when URL changes (and not editing)
    if (!_isEditing && _controller.text != browserState.currentUrl) {
      _controller.text = browserState.currentUrl;
    }

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(
              PhosphorIcons.caretLeft(),
              size: 20,
              color: browserState.canGoBack ? Colors.black87 : Colors.grey,
            ),
            onPressed:
                browserState.canGoBack
                    ? () {
                      // Will be handled by browser screen
                    }
                    : null,
          ),
          // Forward button
          IconButton(
            icon: Icon(
              PhosphorIcons.caretRight(),
              size: 20,
              color: browserState.canGoForward ? Colors.black87 : Colors.grey,
            ),
            onPressed:
                browserState.canGoForward
                    ? () {
                      // Will be handled by browser screen
                    }
                    : null,
          ),
          // URL input
          Expanded(
            child: GestureDetector(
              onTap:
                  widget.readOnly
                      ? null
                      : () => setState(() => _isEditing = true),
              child:
                  _isEditing && !widget.readOnly
                      ? TextField(
                        controller: _controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          hintText: 'Enter URL...',
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 14),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.go,
                        onSubmitted: (_) => _submitUrl(),
                        onTapOutside: (_) {
                          setState(() => _isEditing = false);
                          FocusScope.of(context).unfocus();
                        },
                      )
                      : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          browserState.currentUrl.isEmpty
                              ? 'Enter URL...'
                              : browserState.currentUrl,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                browserState.currentUrl.isEmpty
                                    ? Colors.grey
                                    : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
            ),
          ),
          // Refresh/Stop button
          if (browserState.isLoading)
            IconButton(
              icon: Icon(PhosphorIcons.x(), size: 20, color: Colors.black87),
              onPressed: () {
                // Will be handled by browser screen
              },
            )
          else
            IconButton(
              icon: Icon(
                PhosphorIcons.arrowClockwise(),
                size: 20,
                color: Colors.black87,
              ),
              onPressed: widget.onRefresh,
            ),
        ],
      ),
    );
  }
}

/// Loading progress indicator
class UrlBarProgress extends ConsumerWidget {
  const UrlBarProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browserState = ref.watch(browserProvider);

    if (!browserState.isLoading) {
      return const SizedBox.shrink();
    }

    return LinearProgressIndicator(
      value: browserState.progress,
      backgroundColor: Colors.transparent,
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).colorScheme.primary,
      ),
      minHeight: 2,
    );
  }
}
