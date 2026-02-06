import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/user_profile.dart';
import '../data/models/personal_info.dart';
import '../data/models/contact_info.dart';
import '../data/models/education_info.dart';
import '../data/models/asset_paths.dart';

/// Box name for user profile storage
const String kUserProfileBox = 'user_profile_box';
const String kUserProfileKey = 'main_profile';

/// Provider for the Hive box
final userProfileBoxProvider = FutureProvider<Box<UserProfile>>((ref) async {
  return Hive.openBox<UserProfile>(kUserProfileBox);
});

/// Provider for the current user profile
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
      return UserProfileNotifier(ref);
    });

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final Ref ref;
  Box<UserProfile>? _box;

  UserProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await ref.read(userProfileBoxProvider.future);
      final profile = _loadProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  UserProfile _loadProfile() {
    final profile = _box?.get(kUserProfileKey);
    if (profile != null) {
      return profile;
    }
    // Create demo profile for testing
    final newProfile = UserProfile.demo();
    _box?.put(kUserProfileKey, newProfile);
    return newProfile;
  }

  /// Update personal info
  Future<void> updatePersonal(PersonalInfo personal) async {
    state.whenData((current) async {
      current.personal = personal;
      current.updatedAt = DateTime.now();
      await current.save();
      state = AsyncValue.data(current);
    });
  }

  /// Update contact info
  Future<void> updateContact(ContactInfo contact) async {
    state.whenData((current) async {
      current.contact = contact;
      current.updatedAt = DateTime.now();
      await current.save();
      state = AsyncValue.data(current);
    });
  }

  /// Add or update education entry
  Future<void> upsertEducation(EducationInfo education, {int? index}) async {
    state.whenData((current) async {
      current.education ??= [];

      if (index != null && index < current.education!.length) {
        current.education![index] = education;
      } else {
        current.education!.add(education);
      }

      current.updatedAt = DateTime.now();
      await current.save();
      state = AsyncValue.data(current);
    });
  }

  /// Remove education entry by index
  Future<void> removeEducation(int index) async {
    state.whenData((current) async {
      if (current.education != null && index < current.education!.length) {
        current.education!.removeAt(index);
        current.updatedAt = DateTime.now();
        await current.save();
        state = AsyncValue.data(current);
      }
    });
  }

  /// Update asset paths
  Future<void> updateAssets(AssetPaths assets) async {
    state.whenData((current) async {
      current.assets = assets;
      current.updatedAt = DateTime.now();
      await current.save();
      state = AsyncValue.data(current);
    });
  }

  /// Update a single asset path
  Future<void> updateAssetPath(String assetType, String path) async {
    state.whenData((current) async {
      current.assets ??= AssetPaths();

      switch (assetType.toLowerCase()) {
        case 'photo':
          current.assets!.photoPath = path;
          break;
        case 'signature':
          current.assets!.signaturePath = path;
          break;
        case 'thumb':
        case 'thumb impression':
          current.assets!.thumbImpressionPath = path;
          break;
        case 'caste':
        case 'caste certificate':
          current.assets!.casteCertificatePath = path;
          break;
        case 'income':
        case 'income certificate':
          current.assets!.incomeCertificatePath = path;
          break;
        case 'domicile':
        case 'domicile certificate':
          current.assets!.domicileCertificatePath = path;
          break;
        case 'id':
        case 'id proof':
          current.assets!.idProofPath = path;
          break;
      }

      current.updatedAt = DateTime.now();
      await current.save();
      state = AsyncValue.data(current);
    });
  }

  /// Clear all profile data
  Future<void> clearProfile() async {
    await _box?.delete(kUserProfileKey);
    final newProfile = UserProfile.empty();
    _box?.put(kUserProfileKey, newProfile);
    state = AsyncValue.data(newProfile);
  }
}

/// Provider for searchable text fields
final searchableFieldsProvider = Provider.family<Map<String, String>, String>((
  ref,
  query,
) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile.searchFields(query),
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Provider for available assets
final availableAssetsProvider = Provider<Map<String, String>>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile.assets?.availableAssets ?? {},
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Provider for profile completion percentage
final profileCompletionProvider = Provider<int>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile.completionPercentage,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
