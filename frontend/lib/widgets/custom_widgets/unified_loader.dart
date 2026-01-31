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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      // Blurry Background
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          width: double.infinity,
          height: double.infinity,
        ),
      ),
      // Centered Loader
      Center(
        child: Container(
          padding: const EdgeInsets.all(24),
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
                builder:
                    (context, child) => Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: child,
                      ),
                    ),
                child: Image.asset(
                  'assets/images/logo.png', // Ensure this asset exists, or use a placeholder Icon
                  width: 60,
                  height: 60,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.school_rounded,
                        size: 60,
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
                  decoration:
                      TextDecoration.none, // Since we might be outside Scaffold
                  fontFamily: 'Inter', // Assuming Inter is used
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
