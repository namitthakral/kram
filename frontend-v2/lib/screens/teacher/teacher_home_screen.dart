import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'Teacher Dashboard',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Navigate to notifications
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    authService.logout();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('Profile'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings_outlined),
                      title: Text('Settings'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('Logout', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.onPrimary,
                        child: Text(
                          user?.name.isNotEmpty == true 
                              ? user!.name[0].toUpperCase()
                              : 'T',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${user?.name ?? 'Teacher'}!',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inspire and educate your students',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.onPrimary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.institution?.name ?? 'Institution',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Today's Schedule Section
                Text(
                  'Today\'s Classes',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 16),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 48,
                        color: AppColors.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No classes scheduled',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your class schedule will appear here',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.onSurface.withValues(alpha: 0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Quick Actions Grid
                Text(
                  'Quick Actions',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildQuickActionCard(
                      context,
                      'Attendance',
                      'Mark student attendance',
                      Icons.how_to_reg_outlined,
                      AppColors.primary,
                      () {
                        // TODO: Navigate to attendance
                      },
                    ),
                    _buildQuickActionCard(
                      context,
                      'Assignments',
                      'Create & manage assignments',
                      Icons.assignment_outlined,
                      AppColors.info,
                      () {
                        // TODO: Navigate to assignments
                      },
                    ),
                    _buildQuickActionCard(
                      context,
                      'Grades',
                      'Enter student grades',
                      Icons.grade_outlined,
                      AppColors.warning,
                      () {
                        // TODO: Navigate to grades
                      },
                    ),
                    _buildQuickActionCard(
                      context,
                      'Classes',
                      'View my classes',
                      Icons.class_outlined,
                      AppColors.success,
                      () {
                        // TODO: Navigate to classes
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}