import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../../widgets/quick_observation_modal.dart';
import '../../widgets/teacher_bottom_nav.dart';
import '../../widgets/teacher_top_bar.dart';

class ClassRosterScreen extends StatefulWidget {
  /// When true, shows back button and own bottom nav (pushed screen).
  /// When false, no back button, relies on shell's bottom nav (tab mode).
  final bool isPushed;

  const ClassRosterScreen({super.key, this.isPushed = false});

  @override
  State<ClassRosterScreen> createState() => _ClassRosterScreenState();
}

class _ClassRosterScreenState extends State<ClassRosterScreen> {
  RosterFilter _selectedFilter = RosterFilter.allStudents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 96,
              left: 24,
              right: 24,
              bottom: widget.isPushed ? 128 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 24),
                _buildFilterChips(),
                const SizedBox(height: 32),
                _buildStudentGrid(context),
                const SizedBox(height: 40),
                _buildDailyInsightCard(context),
              ],
            ),
          ),
          TeacherTopBar(showBackButton: widget.isPushed),
        ],
        ),
      ),
      bottomNavigationBar: widget.isPushed
          ? TeacherBottomNav(
              currentIndex: TeacherNavItem.roster,
              onTap: (item) {
                if (item == TeacherNavItem.dashboard) {
                  Navigator.of(context).pop();
                } else if (item != TeacherNavItem.roster) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} tapped (placeholder)')),
                  );
                }
              },
            )
          : null,
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Class Roster',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.75,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track daily logs and student engagement.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'All Students',
            icon: Icons.all_inclusive,
            isActive: _selectedFilter == RosterFilter.allStudents,
            onTap: () => setState(() => _selectedFilter = RosterFilter.allStudents),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Groups',
            icon: Icons.group_outlined,
            isActive: _selectedFilter == RosterFilter.groups,
            onTap: () => setState(() => _selectedFilter = RosterFilter.groups),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Needs Log',
            icon: Icons.assignment_outlined,
            isActive: _selectedFilter == RosterFilter.needsLog,
            onTap: () => setState(() => _selectedFilter = RosterFilter.needsLog),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentGrid(BuildContext context) {
    final students = _getFilteredStudents();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 40,
        crossAxisSpacing: 24,
        childAspectRatio: 0.75,
      ),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return _StudentAvatarCard(
          student: student,
          onTap: () {
            QuickObservationModal.show(context, student);
          },
        );
      },
    );
  }

  List<RosterStudent> _getFilteredStudents() {
    switch (_selectedFilter) {
      case RosterFilter.allStudents:
        return ClassRosterMockData.students;
      case RosterFilter.groups:
        return ClassRosterMockData.students;
      case RosterFilter.needsLog:
        return ClassRosterMockData.students
            .where((s) => !s.isLogged)
            .toList();
    }
  }

  Widget _buildDailyInsightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(33),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.08),
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
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurpleLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Daily Insight',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.6,
              ),
              children: [
                TextSpan(
                  text: '${ClassRosterMockData.loggedPercent}%',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurpleLight,
                  ),
                ),
                const TextSpan(
                  text: ' of your roster has been logged today. Attendance is tracking higher than last Monday by ',
                ),
                TextSpan(
                  text: '${ClassRosterMockData.attendanceImprovement}%',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('View Detailed Insights tapped')),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'View Detailed Insights',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.purpleMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum RosterFilter {
  allStudents,
  groups,
  needsLog,
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryPurple : AppColors.lavenderPlaceholder,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentAvatarCard extends StatelessWidget {
  final RosterStudent student;
  final VoidCallback onTap;

  const _StudentAvatarCard({
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: student.isLogged
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryPurple,
                            AppColors.primaryPurpleLight,
                          ],
                        )
                      : null,
                  color: student.isLogged ? null : const Color(0xFFDAE2FD),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: student.avatarUrl,
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
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: student.isLogged
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFCBD5E1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            student.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.35,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
