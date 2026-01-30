import 'package:flutter/material.dart';

import '../../../../utils/custom_colors.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class StaffScheduleScreen extends StatelessWidget {
  const StaffScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock staff data
    const userInitials = 'SJ';
    const userName = 'Sarah Jones';
    const department = 'Administration';

    return CustomMainScreenWithAppbar(
      title: 'Staff Schedule',
      appBarConfig: AppBarConfig.staff(
        userInitials: userInitials,
        userName: userName,
        department: department,
        onNotificationIconPressed: () {},
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDaySchedule('Monday', [
            '09:00 AM - Shift Start',
            '01:00 PM - Lunch Break',
            '05:00 PM - Shift End',
          ]),
          _buildDaySchedule('Tuesday', [
            '09:00 AM - Shift Start',
            '11:00 AM - Team Meeting',
            '05:00 PM - Shift End',
          ]),
          _buildDaySchedule('Wednesday', [
            '09:00 AM - Shift Start',
            '02:00 PM - Training Session',
            '05:00 PM - Shift End',
          ]),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(String day, List<String> events) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: CustomAppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(event),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
