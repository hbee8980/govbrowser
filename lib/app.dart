import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Main application widget
class GovBrowserApp extends ConsumerWidget {
  const GovBrowserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'GovBrowser',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Router
      routerConfig: appRouter,
    );
  }
}
