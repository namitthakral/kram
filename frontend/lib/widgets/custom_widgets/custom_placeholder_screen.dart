import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/login_signup/login_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/user_utils.dart';
import 'custom_main_screen_with_appbar.dart';

class CustomPlaceholderScreen extends StatelessWidget {
  const CustomPlaceholderScreen({
    required this.title,
    this.pageTitle,
    super.key,
  });

  final String title;
  final String? pageTitle;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginProvider>().currentUser;
    final userInitials = user != null ? UserUtils.getInitials(user.name) : 'US';
    final userName = user?.name ?? 'User';

    // Helper to determine role-specific app bar config
    // This assumes the context has the necessary providers or logic to determine role
    // For now, we use a generic approach or default to student for simplicity in this shared widget
    // Ideally, this should be passed in or derived more robustly

    // Using a generic app bar config based on the title context if possible,
    // or defaulting to a simple version.
    // Since AppBarConfig requires specific named constructors, we'll use a default one for now.

    return CustomMainScreenWithAppbar(
      title: title,
      appBarConfig: _getAppBarConfig(context, user, userInitials, userName),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              pageTitle ?? '$title Coming Soon',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This module is currently under development.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  // Fallback for when there's no history (e.g. initial route or replaced route)
                  // In a real app, you might want to navigate to the dashboard index
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Already at the root of this section'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: CustomAppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBarConfig _getAppBarConfig(
    BuildContext context,
    user, // User model
    String userInitials,
    String userName,
  ) {
    if (user == null) {
      return const AppBarConfig.standard();
    }

    switch (user.role?.id) {
      case 3: // Student
        return AppBarConfig.student(
          userInitials: userInitials,
          userName: userName,
          grade: user.studentClass ?? 'Class X', // Fallback or fetch from user
          rollNumber: user.rollNumber ?? '000', // Fallback or fetch from user
          onNotificationIconPressed: () {},
        );
      case 4: // Parent
        return AppBarConfig.parent(
          childInitials: 'CH', // TODO: Get child initials
          childName: 'Student Name', // TODO: Get child name
          grade: 'Class X', // TODO: Get child class
          rollNumber: '000', // TODO: Get child roll no
          onNotificationIconPressed: () {},
        );
      case 5: // Teacher
        return AppBarConfig.teacher(
          userInitials: userInitials,
          userName: userName,
          designation: user.designation ?? 'Teacher',
          employeeId: user.employeeId ?? 'EMP000',
          onNotificationIconPressed: () {},
        );
      case 6: // Librarian
        return AppBarConfig.librarian(
          userInitials: userInitials,
          userName: userName,
          libraryName: 'Central Library',
          onNotificationIconPressed: () {},
        );
      case 2: // Admin
        return AppBarConfig.admin(
          userInitials: userInitials,
          userName: userName,
          institutionName: user.institution?.name ?? '',
          onNotificationIconPressed: () {},
        );
      case 7: // Staff
        return AppBarConfig.staff(
          userInitials: userInitials,
          userName: userName,
          department: user.department ?? 'Administration',
          onNotificationIconPressed: () {},
        );
      case 1: // Super Admin
        return AppBarConfig.superAdmin(
          userInitials: userInitials,
          userName: userName,
          systemName: 'Kram System',
          onNotificationIconPressed: () {},
        );
      default:
        return const AppBarConfig.standard();
    }
  }
}
