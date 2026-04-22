import 'package:flutter/material.dart';

import '../../widgets/teacher_bottom_nav.dart';
import 'class_roster_screen.dart';
import 'insights_screen.dart';
import 'teacher_home_screen.dart';

class TeacherShell extends StatefulWidget {
  const TeacherShell({super.key});

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  TeacherNavItem _currentIndex = TeacherNavItem.dashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex.index,
        children: const [
          TeacherHomeScreen(),
          ClassRosterScreen(),
          InsightsScreen(),
        ],
      ),
      bottomNavigationBar: TeacherBottomNav(
        currentIndex: _currentIndex,
        onTap: (item) {
          setState(() {
            _currentIndex = item;
          });
        },
      ),
    );
  }
}
