import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../features/feed/presentation/screens/feed_screen.dart';
import '../features/browser/presentation/screens/browser_screen.dart';
import '../features/vault/presentation/screens/vault_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/profile_setup_screen.dart';

/// Shell screen with bottom navigation
class MainShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainShell({super.key, required this.child, required this.currentIndex});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/browser');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(
        0xFFF5F7FA,
      ), // Light grey-blue background for trust
      appBar: AppBar(
        title: const Text(
          'GovBrowser',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFF1E293B), // Slate 800
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
        actions: [
          if (widget.currentIndex != 0)
            IconButton(
              icon: Icon(PhosphorIcons.house(), color: const Color(0xFF64748B)),
              onPressed: () => context.go('/'),
              tooltip: 'Home',
            ),
          IconButton(
            icon: Icon(
              PhosphorIcons.magnifyingGlass(),
              color: const Color(0xFF64748B),
            ), // Slate 500
            onPressed: () => context.go('/browser'),
            tooltip: 'Search',
          ),
          Container(
            margin: const EdgeInsets.only(right: 16, left: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () => context.push('/vault'),
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(
                  PhosphorIcons.user(),
                  size: 20,
                  color: const Color(0xFF0F172A), // Slate 900
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          widget.child,

          if (widget.currentIndex != 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NavButton(
                        icon: PhosphorIcons.briefcase(),
                        activeIcon: PhosphorIcons.briefcase(
                          PhosphorIconsStyle.fill,
                        ),
                        label: 'Jobs',
                        isActive: widget.currentIndex == 0,
                        onTap: () => _onItemTapped(0),
                      ),
                      const SizedBox(width: 8),
                      _NavButton(
                        icon: PhosphorIcons.bookOpen(),
                        activeIcon: PhosphorIcons.bookOpen(
                          PhosphorIconsStyle.fill,
                        ),
                        label: 'Study',
                        isActive: widget.currentIndex == 1,
                        onTap: () => _onItemTapped(1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? Theme.of(context).colorScheme.primary : Colors.grey[600];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color:
              isActive
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(isActive ? activeIcon : icon, color: color, size: 24),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Application router configuration with ShellRoute for navigation
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      name: 'profile-setup',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ProfileSetupScreen(
          email: extra?['email'] as String?,
          phone: extra?['phone'] as String?,
        );
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        // Determine current index based on route
        int currentIndex = 0;
        final location = state.uri.path;
        if (location.startsWith('/browser')) {
          currentIndex = 1;
        } else if (location.startsWith('/vault')) {
          currentIndex = 2;
        }

        return MainShell(currentIndex: currentIndex, child: child);
      },
      routes: [
        // Home (Feed)
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const FeedScreen(),
        ),

        // Browser
        GoRoute(
          path: '/browser',
          name: 'browser',
          builder: (context, state) {
            final url = state.extra as String?;
            return BrowserScreen(initialUrl: url);
          },
        ),

        // Vault (Profile)
        GoRoute(
          path: '/vault',
          name: 'vault',
          builder: (context, state) => const VaultScreen(),
        ),
      ],
    ),
  ],
);
