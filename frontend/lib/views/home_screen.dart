import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as web;

import '../core/theme/app_theme.dart';
import '../modules/ai_assistant/views/ai_chat_screen.dart';
import '../provider/bottom_nav_provider.dart';
import '../provider/login_signup/login_provider.dart';
import '../utils/custom_snackbar.dart';
import '../utils/extensions.dart';
import '../utils/platform_helper.dart';
import '../utils/router_service.dart';
import '../widgets/custom_widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_widgets/custom_dialog.dart';
import '../widgets/custom_widgets/custom_navigation_rail.dart';
import '../widgets/custom_widgets/draggable_floating_overlay.dart';

/// Holds the callback to show logout dialog when browser back is pressed on web.
class _WebBackButtonCallbackHolder {
  static void Function()? _callback;

  static void set(void Function()? cb) {
    _callback = cb;
  }

  static void invoke() {
    _callback?.call();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.child, super.key});

  final Widget child;

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

  Future<void> _initializeNavigation() async {
    final loginProvider = context.read<LoginProvider>();
    final navProvider = context.read<BottomNavProvider>();

    // Check if user is already loaded
    if (loginProvider.currentUser?.role?.id != null) {
      navProvider.initializeForRole(loginProvider.currentUser!.role!.id);
      return;
    }

    // If no user loaded, try to restore session
    // This handles hot restart case where provider state is lost but auth token exists
    final isLoggedIn = await loginProvider.checkLoginStatus();

    if (!mounted) {
      return;
    }

    if (isLoggedIn && loginProvider.currentUser?.role?.id != null) {
      navProvider.initializeForRole(loginProvider.currentUser!.role!.id);
    } else {
      // If still no valid session/role, redirect to login
      context.router.goToLogin();
    }
  }

  @override
  Widget build(BuildContext context) =>
      _HomeScreenContent(scaffoldKey: _scaffoldKey, child: widget.child);
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent({required this.scaffoldKey, required this.child});
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget child;

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  bool _isEndDrawerOpen = false;

  static bool _webBackListenerRegistered = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && !_HomeScreenContentState._webBackListenerRegistered) {
      _HomeScreenContentState._webBackListenerRegistered = true;
      _registerWebBackButtonListener();
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      _WebBackButtonCallbackHolder.set(null);
    }
    super.dispose();
  }

  void _registerWebBackButtonListener() {
    web.window.onPopState.listen((web.PopStateEvent event) {
      final path = web.window.location.pathname ?? '';
      final isLeavingDashboard = path == '/' ||
          path == '/login' ||
          path == '/splash' ||
          path == '/onboarding' ||
          path.isEmpty;
      if (!isLeavingDashboard) return;
      web.window.history.pushState(null, '', '/dashboard');
      RouterService().router.go('/dashboard');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _WebBackButtonCallbackHolder.invoke();
      });
    });
  }

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
  Widget build(BuildContext context) {
    if (kIsWeb) {
      _WebBackButtonCallbackHolder.set(() {
        if (mounted) _showLogoutDialog(context);
      });
    }
    return Consumer<BottomNavProvider>(
      builder: (context, navProvider, _) {
        // Check if navigation is initialized
        if (navProvider.navigationItems.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // When we can pop (e.g. assignment detail), allow back. When at root, show logout.
        final canPop = RouterService().router.canPop();
        return PopScope(
          canPop: canPop,
          onPopInvokedWithResult: (bool didPop, result) {
            if (didPop) {
              return;
            }
            // Defer to next frame so back handling is complete before showing dialog
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                _showLogoutDialog(context);
              }
            });
          },
          child: _buildScaffold(context, navProvider),
        );
    },
  );
  }

  Widget _buildScaffold(BuildContext context, BottomNavProvider navProvider) {
    // Mobile (native iOS/Android or mobile screen size on web) → Use Bottom Bar
    if (_shouldUseBottomBar(context)) {
      return DraggableFloatingOverlay(
        isVisible: !_isEndDrawerOpen,
        onPressed: () => widget.scaffoldKey.currentState?.openEndDrawer(),
        child: Scaffold(
          key: widget.scaffoldKey,
          body: widget.child,
          bottomNavigationBar: const CustomBottomNavBar(),
          endDrawer: const Drawer(
            width: 380, // Slightly wider for chat
            child: AiChatScreen(),
          ),
          onEndDrawerChanged: (isOpen) {
            setState(() {
              _isEndDrawerOpen = isOpen;
            });
          },
          drawerEnableOpenDragGesture: false, // Prevent accidental swipe
        ),
      );
    }

    // Desktop/Tablet (other platforms or larger screens) → Use Overlay Rail
    return DraggableFloatingOverlay(
      isVisible: !_isEndDrawerOpen,
      onPressed: () => widget.scaffoldKey.currentState?.openEndDrawer(),
      child: Scaffold(
        key: widget.scaffoldKey,
        body: _HomeScreenWithRail(child: widget.child),
        endDrawer: const Drawer(
          width: 400, // Wide drawer for desktop
          child: AiChatScreen(),
        ),
        onEndDrawerChanged: (isOpen) {
          setState(() {
            _isEndDrawerOpen = isOpen;
          });
        },
        drawerEnableOpenDragGesture: false,
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    // Use root navigator so dialog appears above shell (dashboard) and is not lost
    final result = await CustomDialog.showConfirmation(
      context: context,
      title: context.translate('logout_title'),
      message: context.translate('logout_message'),
      confirmText: context.translate('logout'),
      cancelText: context.translate('cancel'),
      confirmColor: AppTheme.danger,
      icon: Icons.logout_rounded,
      iconColor: AppTheme.danger,
      useRootNavigator: true,
    );

    if (result != true || !context.mounted) {
      return;
    }

    // Same full logout flow as drawer/rail logout button
    final loginProvider = context.read<LoginProvider>();
    final navigator = Navigator.of(context, rootNavigator: true);

    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder:
            (BuildContext loadingContext) =>
                const Center(child: CircularProgressIndicator()),
      ),
    );

    await loginProvider.logout();

    if (!context.mounted) {
      return;
    }
    navigator.pop(); // Close loading dialog

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.router.goToLogin();
        showCustomSnackbar(
          message: context.translate('logout_success'),
          type: SnackbarType.success,
        );
      }
    });
  }
}

class _HomeScreenWithRail extends StatefulWidget {
  const _HomeScreenWithRail({required this.child});
  final Widget child;

  @override
  State<_HomeScreenWithRail> createState() => _HomeScreenWithRailState();
}

class _HomeScreenWithRailState extends State<_HomeScreenWithRail> {
  bool _isRailExtended = false;
  final GlobalKey<CustomNavigationRailState> _railKey = GlobalKey();

  @override
  Widget build(BuildContext context) => Consumer<BottomNavProvider>(
    builder: (context, navProvider, _) {
      // Check if navigation is initialized
      if (navProvider.navigationItems.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Stack(
        children: [
          // Main content with left padding to avoid rail overlap
          Padding(
            padding: const EdgeInsets.only(left: 80),
            child: widget.child,
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
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.2),
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
