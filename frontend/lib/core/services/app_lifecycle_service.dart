import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/login_signup/login_provider.dart';
import 'auth_service.dart';

/// Service to handle app lifecycle events
/// Automatically refreshes tokens when app resumes from background
class AppLifecycleService extends WidgetsBindingObserver {
  factory AppLifecycleService() => _instance;
  AppLifecycleService._();
  static final AppLifecycleService _instance = AppLifecycleService._();

  final AuthService _authService = AuthService();
  BuildContext? _context;
  bool _isRefreshing = false;

  /// Initialize the lifecycle service with context
  void init(BuildContext context) {
    _context = context;
    WidgetsBinding.instance.addObserver(this);
    log('AppLifecycleService initialized');
  }

  /// Dispose the lifecycle service
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _context = null;
    log('AppLifecycleService disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    log('App lifecycle state changed: $state');

    // Skip lifecycle handling on web - it can cause navigation issues
    // Web apps don't really have background/foreground states like mobile
    if (kIsWeb) {
      log('Skipping lifecycle handling on web platform');
      return;
    }

    // When app resumes from background, check and refresh token
    if (state == AppLifecycleState.resumed) {
      _handleAppResume();
    }
  }

  /// Handle app resume - check and refresh token if needed
  Future<void> _handleAppResume() async {
    if (_isRefreshing || _context == null || !_context!.mounted) {
      return;
    }

    _isRefreshing = true;

    try {
      log('App resumed - checking token status');

      // Check if user is logged in
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
        log('User not logged in, skipping token refresh');
        _isRefreshing = false;
        return;
      }

      // Check if token is expired or about to expire
      final isExpired = await _authService.isTokenExpired();
      if (isExpired) {
        log('Token expired or expiring soon - refreshing...');

        try {
          // Attempt to refresh the token
          await _authService.refreshToken();
          log('Token refreshed successfully');

          // Update user data in LoginProvider
          if (_context != null && _context!.mounted) {
            final loginProvider = _context!.read<LoginProvider>();
            await loginProvider.checkLoginStatus();
            log('User data reloaded after token refresh');
          }
        } on Exception catch (e) {
          log('Token refresh failed: $e');
          // Token refresh failed - user will be logged out on next API call
        }
      } else {
        log('Token is still valid, no refresh needed');
      }
    } on Exception catch (e) {
      log('Error during app resume token check: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  /// Manually trigger token refresh check (useful for testing)
  Future<void> checkAndRefreshToken() async {
    await _handleAppResume();
  }
}
