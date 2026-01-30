import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginProvider>().currentUser;
    final userInitials = user != null ? UserUtils.getInitials(user.name) : 'ST';
    final userName = user?.name ?? 'Student';
    final grade = user?.student?.gradeLevel ?? 'Class 10';
    final rollNumber = user?.student?.rollNumber ?? '23';

    return CustomMainScreenWithAppbar(
      title: 'Events',
      appBarConfig: AppBarConfig.student(
        userInitials: userInitials,
        userName: userName,
        grade: grade,
        rollNumber: rollNumber,
        onNotificationIconPressed: () {},
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEventCard(
            context,
            'Oct',
            '28',
            'Science Fair',
            'Main Auditorium',
            '9:00 AM - 2:00 PM',
            Colors.blue,
          ),
          _buildEventCard(
            context,
            'Nov',
            '05',
            'Sports Day',
            'School Ground',
            '8:00 AM - 4:00 PM',
            Colors.orange,
          ),
          _buildEventCard(
            context,
            'Nov',
            '14',
            'Children\'s Day Celebration',
            'Assembly Hall',
            '10:00 AM - 12:00 PM',
            Colors.pink,
          ),
          _buildEventCard(
            context,
            'Dec',
            '20',
            'Annual Cultural Fest',
            'Main Auditorium',
            '5:00 PM - 9:00 PM',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    String month,
    String day,
    String title,
    String location,
    String time,
    Color color,
  ) => Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    month.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
