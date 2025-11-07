import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/parent/screens/parent_dashboard_screen.dart';
import '../modules/student/screens/student_dashboard_screen.dart';
import '../modules/teacher/screens/teacher_dashboard_screen.dart';
import '../provider/bottom_nav_provider.dart';
import '../widgets/custom_widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_widgets/custom_navigation_rail.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  static final List<Widget> _pages = [
    const StudentDashboardScreen(),
    const TeacherDashboardScreen(),
    const ParentDashboardScreen(),
    const Center(child: Text('Screen 4')),
    // const Center(child: Text('Screen 5')),
    // StoreMain(),
    // Center(child: Text('Message Screen')),
    const ProfileScreen(),
  ];

  /// Check if should use bottom bar (mobile platforms or mobile screen sizes)
  bool _shouldUseBottomBar(BuildContext context) {
    // On native platforms, always use bottom bar for iOS/Android
    // (regardless of orientation or screen size)
    if (!kIsWeb) {
      return Platform.isIOS || Platform.isAndroid;
    }

    // On web, check if device is mobile-sized in ANY orientation
    // Use the shorter dimension to detect mobile devices in landscape
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    // If the shortest side is less than mobile breakpoint, treat as mobile
    return shortestSide < 600;
  }

  @override
  Widget build(BuildContext context) => Consumer<BottomNavProvider>(
    builder: (context, navProvider, child) {
      // Mobile (native iOS/Android or mobile screen size on web) → Use Bottom Bar
      if (_shouldUseBottomBar(context)) {
        return Scaffold(
          body: _pages[navProvider.currentIndex],
          bottomNavigationBar: const CustomBottomNavBar(),
        );
      }

      // Desktop/Tablet (other platforms or larger screens) → Use Overlay Rail
      return const Scaffold(body: _HomeScreenWithRail());
    },
  );
}

class _HomeScreenWithRail extends StatefulWidget {
  const _HomeScreenWithRail();

  @override
  State<_HomeScreenWithRail> createState() => _HomeScreenWithRailState();
}

class _HomeScreenWithRailState extends State<_HomeScreenWithRail> {
  bool _isRailExtended = false;
  final GlobalKey<CustomNavigationRailState> _railKey = GlobalKey();

  @override
  Widget build(BuildContext context) => Consumer<BottomNavProvider>(
    builder:
        (context, navProvider, child) => Stack(
          children: [
            // Main content with left padding to avoid rail overlap
            Padding(
              padding: const EdgeInsets.only(left: 80),
              child: HomeScreen._pages[navProvider.currentIndex],
            ),
            // Backdrop overlay when rail is extended
            if (_isRailExtended)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    // Collapse the rail by calling its method
                    _railKey.currentState?.setExtended(false);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),
              ),
            // Navigation rail overlay
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: CustomNavigationRail(
                key: _railKey,
                onExtendedChanged: (isExtended) {
                  setState(() {
                    _isRailExtended = isExtended;
                  });
                },
              ),
            ),
          ],
        ),
  );
}
