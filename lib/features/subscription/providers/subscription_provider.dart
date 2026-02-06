import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Subscription tiers
enum SubscriptionTier { free, pro }

/// State class for subscription
class SubscriptionState {
  final SubscriptionTier tier;
  final bool isServerMonitorEnabled;
  final bool isCloudBackupEnabled;

  const SubscriptionState({
    this.tier = SubscriptionTier.free,
    this.isServerMonitorEnabled = false,
    this.isCloudBackupEnabled = false,
  });

  bool get isPro => tier == SubscriptionTier.pro;

  SubscriptionState copyWith({
    SubscriptionTier? tier,
    bool? isServerMonitorEnabled,
    bool? isCloudBackupEnabled,
  }) {
    return SubscriptionState(
      tier: tier ?? this.tier,
      isServerMonitorEnabled:
          isServerMonitorEnabled ?? this.isServerMonitorEnabled,
      isCloudBackupEnabled: isCloudBackupEnabled ?? this.isCloudBackupEnabled,
    );
  }
}

/// Provider to manage subscription state
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionState());

  void upgradeToPro() {
    state = state.copyWith(
      tier: SubscriptionTier.pro,
      isServerMonitorEnabled: true,
      isCloudBackupEnabled: true,
    );
  }

  void downgradeToFree() {
    state = const SubscriptionState(); // Reset only to free defaults
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});
