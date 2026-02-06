import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for the browser
class BrowserState {
  final String currentUrl;
  final String? title;
  final bool isLoading;
  final double progress;
  final bool canGoBack;
  final bool canGoForward;
  final bool isOverlayExpanded;

  const BrowserState({
    this.currentUrl = '',
    this.title,
    this.isLoading = false,
    this.progress = 0.0,
    this.canGoBack = false,
    this.canGoForward = false,
    this.isOverlayExpanded = false,
  });

  BrowserState copyWith({
    String? currentUrl,
    String? title,
    bool? isLoading,
    double? progress,
    bool? canGoBack,
    bool? canGoForward,
    bool? isOverlayExpanded,
  }) {
    return BrowserState(
      currentUrl: currentUrl ?? this.currentUrl,
      title: title ?? this.title,
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      isOverlayExpanded: isOverlayExpanded ?? this.isOverlayExpanded,
    );
  }
}

/// Provider for browser state
final browserProvider = StateNotifierProvider<BrowserNotifier, BrowserState>((
  ref,
) {
  return BrowserNotifier();
});

class BrowserNotifier extends StateNotifier<BrowserState> {
  BrowserNotifier() : super(const BrowserState());

  /// Update URL
  void updateUrl(String url) {
    state = state.copyWith(currentUrl: url);
  }

  /// Update title
  void updateTitle(String? title) {
    state = state.copyWith(title: title);
  }

  /// Update loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Update progress
  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  /// Update navigation state
  void updateNavigationState({bool? canGoBack, bool? canGoForward}) {
    state = state.copyWith(
      canGoBack: canGoBack ?? state.canGoBack,
      canGoForward: canGoForward ?? state.canGoForward,
    );
  }

  /// Toggle overlay expanded state
  void toggleOverlay() {
    state = state.copyWith(isOverlayExpanded: !state.isOverlayExpanded);
  }

  /// Set overlay expanded state
  void setOverlayExpanded(bool expanded) {
    state = state.copyWith(isOverlayExpanded: expanded);
  }
}

/// Provider for the initial URL (from deep link or default)
final initialUrlProvider = StateProvider<String?>((ref) => null);
