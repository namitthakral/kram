import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../data/mock_data.dart';
import '../screens/teacher/class_selection_screen.dart';

/// Shared top bar for Dashboard, Roster, and Insights tabs.
class TeacherTopBar extends StatelessWidget {
  /// When true, shows back button instead of avatar (for pushed screens).
  final bool showBackButton;

  const TeacherTopBar({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (showBackButton) ...[
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textDark,
                    ),
                    const SizedBox(width: 4),
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: CachedNetworkImage(
                        imageUrl: MockData.teacherAvatarUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.lavenderPlaceholder,
                          child: const Icon(Icons.person),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.lavenderPlaceholder,
                          child: const Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    MockData.teacherName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: AppColors.textDarkAlt,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const ClassSelectionScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.swap_horiz),
                    color: AppColors.textDark,
                    tooltip: 'Switch class',
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications tapped')),
                      );
                    },
                    icon: const Icon(Icons.notifications_outlined),
                    color: AppColors.textDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
