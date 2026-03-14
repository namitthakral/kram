import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/bottom_nav_provider.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/custom_widgets/custom_navigation_drawer.dart';
import '../models/assignment_models.dart';
import '../providers/performance_tab_provider.dart';
import '../services/teacher_service.dart';
import 'teacher_dashboard_screen.dart';

/// Teacher Module Home Screen
/// Shows drawer navigation on web/desktop, regular app bar on mobile
class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final TeacherService _teacherService = TeacherService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _checkClassTeacherStatus(),
    );
  }

  Future<void> _checkClassTeacherStatus() async {
    if (!mounted) return;

    final loginsProvider = context.read<LoginProvider>();
    final user = loginsProvider.currentUser;
    // roleId 5 is teacher.
    if (user?.uuid == null || user?.role?.id != 5) return;

    try {
      // We fetch all classes to find if they are class teacher of any
      final classes = await _teacherService.getTeacherClasses(user!.uuid!);

      if (!mounted) return;

      ClassSection? classTeacherAssignment;
      try {
        classTeacherAssignment = classes.firstWhere((c) => c.isClassTeacher);
      } on Exception catch (_) {
        classTeacherAssignment = null;
      }

      final navProvider = context.read<BottomNavProvider>();
      // Index 1 is 'my_classes' in RoleNavigationConfig for Teacher

      if (classTeacherAssignment != null) {
        // Redirect to detail
        // Path format: /classes/:className/:sectionId?courseId=X
        final path =
            '/classes/${classTeacherAssignment.displayName}/${classTeacherAssignment.id}?courseId=${classTeacherAssignment.courseId}';
        navProvider.overrideRoute(1, path);
      } else {
        // Hide the tab if not a class teacher (per user request)
        navProvider.hideItem(1);
      }
    } on Exception catch (e) {
      debugPrint('Error checking class teacher status: $e');
    }
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => PerformanceTabProvider(),
    child: _buildContent(context),
  );

  Widget _buildContent(BuildContext context) {
    // For web and desktop: Show fixed drawer with dashboard
    if (kIsWeb || context.isDesktop) {
      return const Scaffold(
        body: Row(
          children: [
            // Fixed Navigation Drawer (only on web/desktop)
            CustomNavigationDrawer(),
            // Main Content
            Expanded(child: TeacherDashboardScreen()),
          ],
        ),
      );
    }

    // For mobile: Show regular app bar without drawer
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: const Color(0xFF4F7CFF),
      ),
      body: const TeacherDashboardScreen(),
    );
  }
}
