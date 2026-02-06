import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'features/vault/data/models/user_profile.dart';
import 'features/vault/data/models/personal_info.dart';
import 'features/vault/data/models/contact_info.dart';
import 'features/vault/data/models/education_info.dart';
import 'features/vault/data/models/asset_paths.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (only on mobile)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(PersonalInfoAdapter());
  Hive.registerAdapter(ContactInfoAdapter());
  Hive.registerAdapter(EducationInfoAdapter());
  Hive.registerAdapter(AssetPathsAdapter());

  // Run the app
  runApp(const ProviderScope(child: GovBrowserApp()));
}
