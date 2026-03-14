import 'dart:ui';

import 'package:flutter/material.dart';

import '../../utils/custom_colors.dart';

class UnifiedLoader extends StatefulWidget {
  const UnifiedLoader({super.key});

  @override
  State<UnifiedLoader> createState() => _UnifiedLoaderState();
}

class _UnifiedLoaderState extends State<UnifiedLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Add listener to check mounted state
    _controller.addStatusListener(_onAnimationStatus);

    // Start animation after the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _controller.repeat(reverse: true);
      }
    });
  }

  void _onAnimationStatus(AnimationStatus status) {
    // Stop animation if widget is disposed
    if (_isDisposed || !mounted) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Prevent rendering if disposed
    if (_isDisposed || !mounted) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurry Background - Full screen coverage
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
        ),
        // Centered Loader
        Center(
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // Extra safety check
                    if (_isDisposed || !mounted) {
                      return child ?? const SizedBox.shrink();
                    }
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 80,
                    height: 80,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.school_rounded,
                          size: 80,
                          color: CustomAppColors.primary,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CustomAppColors.slate700,
                    decoration: TextDecoration.none,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
