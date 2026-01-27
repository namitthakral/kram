import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/ai_assistant/views/ai_chat_screen.dart';
import '../provider/bottom_nav_provider.dart';
import '../provider/login_signup/login_provider.dart';
import '../utils/platform_helper.dart';
import '../utils/router_service.dart';
import '../widgets/custom_widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_widgets/custom_navigation_rail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Initialize navigation based on user role
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNavigation();
    });
  }

  void _initializeNavigation() {
    final loginProvider = context.read<LoginProvider>();
    final navProvider = context.read<BottomNavProvider>();
    final user = loginProvider.currentUser;

    if (user?.role?.id != null) {
      navProvider.initializeForRole(user!.role!.id);
    } else {
      // If no role found, redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.router.goToLogin();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      _HomeScreenContent(scaffoldKey: _scaffoldKey);
}

class _HomeScreenContent extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const _HomeScreenContent({required this.scaffoldKey});

  /// Check if should use bottom bar (mobile platforms or mobile screen sizes)
  bool _shouldUseBottomBar(BuildContext context) {
    // On native platforms, always use bottom bar for iOS/Android
    // (regardless of orientation or screen size)
    if (!kIsWeb) {
      return PlatformHelper.isMobilePlatform;
    }

    // On web, check if device is mobile-sized in ANY orientation
    // Use the shorter dimension to detect mobile devices in landscape
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    // If the shortest side is less than mobile breakpoint, treat as mobile
    return shortestSide < 600;
  }

  @override
  Widget build(BuildContext context) => Consumer<BottomNavProvider>(
    builder: (context, navProvider, child) {
      // Check if navigation is initialized
      if (navProvider.pages.isEmpty) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final fab = FloatingActionButton(
        onPressed: () {
          scaffoldKey.currentState?.openEndDrawer();
        },
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      );

      // Mobile (native iOS/Android or mobile screen size on web) → Use Bottom Bar
      if (_shouldUseBottomBar(context)) {
        return Scaffold(
          key: scaffoldKey,
          body: navProvider.pages[navProvider.currentIndex],
          bottomNavigationBar: const CustomBottomNavBar(),
          floatingActionButton: fab,
          endDrawer: const Drawer(
            width: 380, // Slightly wider for chat
            child: AiChatScreen(),
          ),
          drawerEnableOpenDragGesture: false, // Prevent accidental swipe
        );
      }

      // Desktop/Tablet (other platforms or larger screens) → Use Overlay Rail
      return Scaffold(
        key: scaffoldKey,
        body: const _HomeScreenWithRail(),
        floatingActionButton: fab,
        endDrawer: const Drawer(
          width: 400, // Wide drawer for desktop
          child: AiChatScreen(),
        ),
        drawerEnableOpenDragGesture: false,
      );
    },
  );
}

class _HomeScreenWithRail extends StatefulWidget {
  const _HomeScreenWithRail();

  @override
  State<_HomeScreenWithRail> createState() => _HomeScreenWithRailState();
}

class _HomeScreenWithRailState extends State<_HomeScreenWithRail> {
  bool _isRailExtended = false;
  final GlobalKey<CustomNavigationRailState> _railKey = GlobalKey();

  @override
  Widget build(BuildContext context) => Consumer<BottomNavProvider>(
    builder: (context, navProvider, child) {
      // Check if navigation is initialized
      if (navProvider.pages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Stack(
        children: [
          // Main content with left padding to avoid rail overlap
          Padding(
            padding: const EdgeInsets.only(left: 80),
            child: navProvider.pages[navProvider.currentIndex],
          ),
          // Backdrop overlay when rail is extended
          if (_isRailExtended)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Collapse the rail by calling its method
                  _railKey.currentState?.setExtended(false);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          // Navigation rail overlay
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: CustomNavigationRail(
              key: _railKey,
              onExtendedChanged: (isExtended) {
                setState(() {
                  _isRailExtended = isExtended;
                });
              },
            ),
          ),
        ],
      );
    },
  );
}
