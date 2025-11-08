import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/home_screen.dart';
import '../views/login_register/login_register_main.dart';
import '../views/onboarding/onboarding_main.dart';
import '../views/splash_screen.dart';

/// A singleton service to handle routing with go_router
class RouterService {
  factory RouterService() => _instance;
  RouterService._internal();
  // Singleton instance
  static final RouterService _instance = RouterService._internal();

  // Router configuration
  late final GoRouter router;

  // Stream controller for route changes
  final StreamController<String> _routeStreamController =
      StreamController<String>.broadcast();
  Stream<String> get routeStream => _routeStreamController.stream;

  // Initialize the router
  void init() {
    router = GoRouter(
      initialLocation: '/splash',
      // errorBuilder: (context, state) => const NotFoundPage(),
      routes: _routes,
      redirect: _globalRedirect,
      refreshListenable: GoRouterRefreshStream(routeStream),
      observers: [RouteObserver()],
    );
  }

  // Global redirect function for authentication or other global conditions
  String? _globalRedirect(BuildContext context, GoRouterState state) {
    // Example: Check authentication and redirect if needed
    // final isLoggedIn = AuthService().isLoggedIn;
    // final isGoingToLogin = state.location == '/login';

    // if (!isLoggedIn && !isGoingToLogin) {
    //   return '/login?from=${state.location}';
    // }

    return null; // No redirect needed
  }

  // Define all routes
  List<RouteBase> get _routes => [
    GoRoute(
      path: '/splash',
      name: 'splash',
      pageBuilder:
          (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const SplashScreen(),
          ),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      pageBuilder:
          (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const OnboardingMain(),
          ),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder:
          (context, state) =>
              _buildPageWithTransition(key: state.pageKey, child: const HomeScreen()),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder:
          (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const LoginRegisterMain(),
          ),
    ),
  ];

  // Helper method to build pages with consistent fade transition (better for web)
  CustomTransitionPage<void> _buildPageWithTransition({
    required LocalKey key,
    required Widget child,
  }) => CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Use fade transition for web (no slide), looks more native
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
  );

  // Navigation methods
  void goToHome() => router.goNamed('home');

  void goToOnboarding() => router.pushNamed('onboarding');

  void goToProfile(String userId) =>
      router.pushNamed('profile', pathParameters: {'userId': userId});

  void goToSearch() => router.pushNamed('search');

  void goToLogin() => router.pushNamed('login');

  void goToCart() => router.pushNamed('cart');

  void goToCheckout() => router.pushNamed('checkout');

  void gotToProduct(String productId) => router.pushNamed(
    'product_detail',
    pathParameters: {'productId': productId},
  );

  void goBack() => router.pop();

  // Method to navigate by string path (useful for deep links)
  void navigateToPath(String path) => router.go(path);

  // Utility method for deep link handling
  Future<void> handleDeepLink(String link) async {
    final uri = Uri.parse(link);
    final path = uri.path.isEmpty ? '/' : uri.path;

    // Convert URI query parameters to a map
    // final queryParams = uri.queryParameters;

    // Determine the correct route based on path
    if (path.startsWith('/profile/')) {
      final userId = path.split('/').last;
      goToProfile(userId);
    } /*  else if (path == '/settings') {
      goToSettings();
    }  else if (path == '/details') {
      goToDetails(
        productId: queryParams['id'],
        category: queryParams['category'],
      );
    } */ else if (path == '/' || path.isEmpty) {
      goToHome();
    } else {
      // Handle unknown paths or custom deep link formats
      navigateToPath(path);
    }

    // Notify stream about route change
    _routeStreamController.add(path);
  }

  // Clean up resources
  void dispose() {
    _routeStreamController.close();
  }
}

// Extension to make the router globally accessible
extension RouterServiceExtension on BuildContext {
  RouterService get router => RouterService();
}

// Helper class to allow Stream to work with GoRouter's refreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
