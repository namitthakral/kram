import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../../widgets/custom_widgets/custom_tab_bar.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/student_events_provider.dart';
import '../providers/student_provider.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();

    final user = context.watch<LoginProvider>().currentUser;
    final userInitials = user != null ? UserUtils.getInitials(user.name) : 'ST';
    final userName = user?.name ?? 'Student';

    // Get dynamic grade/class info
    final className = studentProvider.studentClassName;
    final section = studentProvider.studentSection;
    final grade =
        (className.isNotEmpty || section.isNotEmpty)
            ? '$className $section'.trim()
            : 'Class N/A';

    final rollNumber = user?.student?.rollNumber ?? 'N/A';

    // Get GPA from dashboard stats
    final statsData = studentProvider.dashboardStats;
    final gpa = statsData?['gpa']?.toString();

    return ChangeNotifierProvider(
      create: (context) {
        final provider = StudentEventsProvider();
        if (user != null) {
          provider.loadEvents(user);
        }
        return provider;
      },
      child: _EventsScreenContent(
        userInitials: userInitials,
        userName: userName,
        grade: grade,
        rollNumber: rollNumber,
        gpa: gpa,
      ),
    );
  }
}

class _EventsScreenContent extends StatefulWidget {
  const _EventsScreenContent({
    required this.userInitials,
    required this.userName,
    required this.grade,
    required this.rollNumber,
    required this.gpa,
  });

  final String userInitials;
  final String userName;
  final String grade;
  final String rollNumber;
  final String? gpa;

  @override
  State<_EventsScreenContent> createState() => _EventsScreenContentState();
}

class _EventsScreenContentState extends State<_EventsScreenContent> {
  Future<void> _selectDateRange(
    BuildContext context,
    StudentEventsProvider provider,
  ) async {
    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final defaultStart = provider.startDate ?? DateTime(now.year, now.month);
    final defaultEnd = provider.endDate ?? now;

    final result = await showDialog<Map<String, DateTime>>(
      context: context,
      builder: (BuildContext dialogContext) {
        var tempStart = defaultStart;
        var tempEnd = defaultEnd;

        return StatefulBuilder(
          builder:
              (context, setState) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: 500,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Date Range',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slate800,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDateTile(
                        label: 'Start Date',
                        date: tempStart,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempStart,
                            firstDate: DateTime(2000),
                            lastDate: tempEnd,
                          );
                          if (picked != null) {
                            setState(() => tempStart = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDateTile(
                        label: 'End Date',
                        date: tempEnd,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempEnd,
                            firstDate: tempStart,
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => tempEnd = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed:
                                () => Navigator.of(
                                  context,
                                ).pop({'start': tempStart, 'end': tempEnd}),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.blue500,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
    );

    if (result != null && mounted) {
      provider.setFilter(
        'custom',
        user,
        customStart: result['start'],
        customEnd: result['end'],
      );
    }
  }

  Widget _buildDateTile({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.slate200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.blue500),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.slate600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slate800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginProvider>().currentUser;

    return CustomMainScreenWithAppbar(
      title: 'Events',
      appBarConfig: AppBarConfig.student(
        userInitials: widget.userInitials,
        userName: widget.userName,
        grade: widget.grade,
        rollNumber: widget.rollNumber,
        gpa: widget.gpa,
        onNotificationIconPressed: () {},
      ),
      child: Consumer<StudentEventsProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomTabBar<String>(
                  tabs: const [
                    TabItem(
                      value: 'upcoming',
                      label: 'Upcoming',
                      icon: Icons.event,
                    ),
                    TabItem(value: 'today', label: 'Today', icon: Icons.today),
                    TabItem(
                      value: 'week',
                      label: 'Week',
                      icon: Icons.view_week,
                    ),
                    TabItem(
                      value: 'month',
                      label: 'Month',
                      icon: Icons.calendar_month,
                    ),
                    TabItem(
                      value: 'custom',
                      label: 'Custom',
                      icon: Icons.date_range,
                    ),
                  ],
                  selectedValue: provider.selectedFilter,
                  onTabSelected: (value) async {
                    if (value == 'custom') {
                      await _selectDateRange(context, provider);
                    } else if (user != null) {
                      provider.setFilter(value, user);
                    }
                  },
                ),
              ),
              Expanded(child: _buildEventsList(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventsList(StudentEventsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text('Error: ${provider.error}'));
    }

    if (provider.events.isEmpty) {
      return const Center(child: Text('No events found in this range'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.events.length,
      itemBuilder: (context, index) {
        final event = provider.events[index];
        final dateStr =
            event['date'] as String? ??
            event['startDate'] as String? ??
            DateTime.now().toIso8601String();
        final date = DateTime.tryParse(dateStr) ?? DateTime.now();

        final month = DateFormat('MMM').format(date);
        final day = DateFormat('dd').format(date);
        String time = event['time'] ?? event['startTime'] ?? 'All Day';
        if (time != 'All Day') {
          try {
            // Check if it's HH:mm format
            final timeParts = time.split(':');
            if (timeParts.length >= 2) {
              final hour = int.parse(timeParts[0]);
              final minute = int.parse(timeParts[1]);
              final dateTime = DateTime(2000, 1, 1, hour, minute);
              time = DateFormat('h:mm a').format(dateTime);
            }
          } catch (e) {
            // Keep original if parsing fails
          }
        }

        return _buildEventCard(
          context,
          month,
          day,
          event['title'] ?? 'Event',
          event['location'] ?? event['subject'] ?? 'School',
          time,
          _getEventColor(event['type']),
        );
      },
    );
  }

  Color _getEventColor(String? type) {
    if (type == null) return Colors.blue;
    switch (type.toLowerCase()) {
      case 'sports':
        return Colors.orange;
      case 'cultural':
        return Colors.purple;
      case 'academic':
      case 'test':
        return Colors.blue;
      case 'holiday':
        return Colors.green;
      case 'assignment':
        return Colors.deepPurple;
      default:
        return Colors.pink;
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
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
