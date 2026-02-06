import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../providers/student_events_provider.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginProvider>().currentUser;
    final userInitials = user != null ? UserUtils.getInitials(user.name) : 'ST';
    final userName = user?.name ?? 'Student';
    final grade = user?.student?.gradeLevel ?? 'Class 10';
    final rollNumber = user?.student?.rollNumber ?? '23';

    return ChangeNotifierProvider(
      create: (context) {
        final provider = StudentEventsProvider();
        if (user != null) {
          provider.loadEvents(user);
        }
        return provider;
      },
      child: CustomMainScreenWithAppbar(
        title: 'Events',
        appBarConfig: AppBarConfig.student(
          userInitials: userInitials,
          userName: userName,
          grade: grade,
          rollNumber: rollNumber,
          onNotificationIconPressed: () {},
        ),
        child: Consumer<StudentEventsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text('Error: ${provider.error}'));
            }

            if (provider.events.isEmpty) {
              return const Center(child: Text('No upcoming events'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.events.length,
              itemBuilder: (context, index) {
                final event = provider.events[index];
                // Assuming event structure: { title, startDate, location, type, etc. }
                // Adjust fields based on actual API response
                final dateStr = event['startDate'] as String? ?? DateTime.now().toIso8601String();
                final date = DateTime.tryParse(dateStr) ?? DateTime.now();

                final month = DateFormat('MMM').format(date);
                final day = DateFormat('dd').format(date);
                final time = event['startTime'] ?? 'All Day';

                return _buildEventCard(
                  context,
                  month,
                  day,
                  event['title'] ?? 'Event',
                  event['location'] ?? 'School',
                  time,
                  _getEventColor(event['type']),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getEventColor(String? type) {
    if (type == null) return Colors.blue;
    switch (type.toLowerCase()) {
      case 'sports': return Colors.orange;
      case 'cultural': return Colors.purple;
      case 'academic': return Colors.blue;
      case 'holiday': return Colors.green;
      default: return Colors.pink;
    }
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
                color: color.withOpacity(0.1),
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
