import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/responsive_utils.dart';
import '../../../widgets/custom_widgets/custom_navigation_drawer.dart';
import '../providers/performance_tab_provider.dart';
import 'teacher_dashboard_screen.dart';

/// Teacher Module Home Screen
/// Shows drawer navigation on web/desktop, regular app bar on mobile
class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

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
