import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/teacher/screens/teacher_dashboard_screen.dart';
import '../provider/bottom_nav_provider.dart';
import '../utils/responsive_utils.dart';
import '../widgets/custom_widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_widgets/custom_navigation_drawer.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Widget> _pages = [
    // Teacher Dashboard - first screen
    const TeacherDashboardScreen(),
    const Center(child: Text('Screen 2')),
    const Center(child: Text('Screen 3')),
    const Center(child: Text('Screen 4')),
    // const Center(child: Text('Screen 5')),
    // StoreMain(),
    // Center(child: Text('Message Screen')),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) => Consumer<BottomNavProvider>(
    builder: (context, navProvider, child) {
      // Use fixed drawer for desktop/tablet
      if (context.isDesktop || context.isTablet) {
        return Scaffold(
          body: Row(
            children: [
              // Fixed drawer on the left
              const CustomNavigationDrawer(),
              // Main content
              Expanded(child: _pages[navProvider.currentIndex]),
            ],
          ),
        );
      }

      // Use bottom navigation for mobile
      return Scaffold(
        body: _pages[navProvider.currentIndex],
        bottomNavigationBar: const CustomBottomNavBar(),
      );
    },
  );
}
