import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock_data.dart';
import 'teacher_shell.dart';

/// First screen - teacher selects which class to manage for the day.
class ClassSelectionScreen extends StatelessWidget {
  const ClassSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 96,
              left: 24,
              right: 24,
              bottom: 48,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(),
                const SizedBox(height: 48),
                _buildClassList(context),
              ],
            ),
          ),
          _buildHeader(context),
        ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: CachedNetworkImage(
                      imageUrl: MockData.teacherAvatarUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.primaryPurpleLight,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.primaryPurpleLight,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Classroom',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: AppColors.textDarkAlt,
                    ),
                  ),
                ],
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
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${MockData.teacherName}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: AppColors.primaryPurple,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.2,
              height: 1.1,
              color: AppColors.textDark,
            ),
            children: [
              const TextSpan(text: 'Choose your\n'),
              TextSpan(
                text: 'class',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.2,
                  height: 1.1,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select a workspace to manage your\nstudents, curriculum, and daily\nsessions.',
          style: GoogleFonts.inter(
            fontSize: 18,
            height: 1.6,
            color: AppColors.tagBlueText,
          ),
        ),
      ],
    );
  }

  Widget _buildClassList(BuildContext context) {
    return Column(
      children: MockData.teacherClasses.map((cls) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _ClassCard(
            teacherClass: cls,
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const TeacherShell(),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final TeacherClass teacherClass;
  final VoidCallback onTap;

  const _ClassCard({
    required this.teacherClass,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = teacherClass.isActiveNow;

    return Container(
      padding: const EdgeInsets.all(33),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isActive) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ACTIVE NOW',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                '${teacherClass.period} • ${teacherClass.time}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.navInactive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            teacherClass.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _InfoChip(
                icon: Icons.door_front_door_outlined,
                label: teacherClass.room,
              ),
              _InfoChip(
                icon: Icons.people_outline,
                label: '${teacherClass.studentCount} Students',
              ),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [AppColors.primaryPurple, AppColors.primaryPurpleLight],
                      )
                    : null,
                color: isActive ? null : AppColors.tagBlue,
                borderRadius: BorderRadius.circular(999),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primaryPurple.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Open Class',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.35,
                      color: isActive ? Colors.white : AppColors.tagBlueText,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
