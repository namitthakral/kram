import 'package:flutter/material.dart';

import '../../../../utils/custom_colors.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class ChildProgressScreen extends StatelessWidget {
  const ChildProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock parent/child data
    const childInitials = 'AS';
    const childName = 'Alice Smith';
    const grade = 'Class 10';
    const rollNumber = '23';

    return CustomMainScreenWithAppbar(
      title: 'Child Progress',
      appBarConfig: AppBarConfig.parent(
        childInitials: childInitials,
        childName: childName,
        grade: grade,
        rollNumber: rollNumber,
        onNotificationIconPressed: () {},
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 20),
            const Text(
              'Recent Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRecommendationItem('Focus on Mathematics algebra concepts.'),
            _buildRecommendationItem('Great improvement in Science lab work.'),
            _buildRecommendationItem('Encourage regular reading habits.'),
            const SizedBox(height: 20),
            const Text(
              'Attendance Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildAttendanceSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('GPA', '3.8', Colors.blue),
        _buildStatItem('Attendance', '95%', Colors.green),
        _buildStatItem('Rank', '5', Colors.orange),
      ],
    ),
  );

  Widget _buildStatItem(String label, String value, Color color) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
    ],
  );

  Widget _buildRecommendationItem(String text) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: CustomAppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    ),
  );

  Widget _buildAttendanceSummary() => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: 0.95,
            backgroundColor: Colors.grey[200],
            color: Colors.green,
            minHeight: 10,
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Days: 120'),
              Text('Present: 114'),
              Text('Absent: 6'),
            ],
          ),
        ],
      ),
    ),
  );
}
