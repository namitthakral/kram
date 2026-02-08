import 'package:flutter/material.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock parent/child data
    const childInitials = 'AS';
    const childName = 'Alice Smith';
    const grade = 'Class 10';
    const rollNumber = '23';

    return CustomMainScreenWithAppbar(
      title: 'Announcements',
      appBarConfig: AppBarConfig.parent(
        childInitials: childInitials,
        childName: childName,
        grade: grade,
        rollNumber: rollNumber,
        onNotificationIconPressed: () {},
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAnnouncementCard(
            'School Closed for Maintenance',
            'Oct 28',
            'The school will remain closed this Friday for scheduled maintenance work. Online classes will be held as per the regular timetable.',
            isImportant: true,
          ),
          _buildAnnouncementCard(
            'Parent-Teacher Meeting',
            'Nov 05',
            'The quarterly Parent-Teacher Meeting is scheduled for Nov 10th. Please book your slots via the app.',
          ),
          _buildAnnouncementCard(
            'Winter Uniform Update',
            'Nov 12',
            'Students are required to wear the winter uniform starting from Dec 1st. Please ensure you have the necessary items.',
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(
    String title,
    String date,
    String content, {
    bool isImportant = false,
  }) => Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isImportant)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'IMPORTANT',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
}
