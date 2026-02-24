import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../providers/student_provider.dart';
import '../providers/student_timetable_provider.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  late String _selectedDay;
  late final StudentTimetableProvider _timetableProvider;

  final Map<String, String> _dayMapping = {
    'Mon': 'MONDAY',
    'Tue': 'TUESDAY',
    'Wed': 'WEDNESDAY',
    'Thu': 'THURSDAY',
    'Fri': 'FRIDAY',
    'Sat': 'SATURDAY',
    'Sun': 'SUNDAY',
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _getCurrentDay();
    _timetableProvider = StudentTimetableProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<LoginProvider>().currentUser;
      if (user != null) {
        _timetableProvider.loadTimetable(user);
      }
    });
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.monday:
        return 'MONDAY';
      case DateTime.tuesday:
        return 'TUESDAY';
      case DateTime.wednesday:
        return 'WEDNESDAY';
      case DateTime.thursday:
        return 'THURSDAY';
      case DateTime.friday:
        return 'FRIDAY';
      case DateTime.saturday:
        return 'SATURDAY';
      case DateTime.sunday:
        return 'SUNDAY';
      default:
        return 'MONDAY';
    }
  }

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

    return ChangeNotifierProvider<StudentTimetableProvider>.value(
      value: _timetableProvider,
      child: CustomMainScreenWithAppbar(
        title: 'Timetable',
        appBarConfig: AppBarConfig.student(
          userInitials: userInitials,
          userName: userName,
          grade: grade,
          rollNumber: rollNumber,
          gpa: gpa,
          onNotificationIconPressed: () {},
        ),
        child: Column(
          children: [
            _buildDaySelector(),
            Expanded(
              child: Consumer<StudentTimetableProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(child: Text('Error: ${provider.error}'));
                  }

                  final dayEntries = provider.timetable[_selectedDay];
                  if (dayEntries == null ||
                      (dayEntries is List && dayEntries.isEmpty)) {
                    return const Center(child: Text('No classes for this day'));
                  }

                  final entries = dayEntries as List<dynamic>;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      // Degrade gracefully if structure differs
                      final subjectName =
                          entry['subject']?['name'] ??
                          entry['subject']?['subjectName'] ??
                          'Subject';
                      final roomName =
                          entry['room']?['roomNumber'] ??
                          entry['room']?['roomName'] ??
                          'Room';

                      // Handle teacher name parsing based on observation log
                      var teacherName = 'Teacher';
                      if (entry['teacher'] != null) {
                        teacherName =
                            entry['teacher']['name'] ??
                            entry['teacher']['user']?['name'] ??
                            'Teacher';
                      }

                      // Format time range
                      final timeSlot = entry['timeSlot'];
                      final startTimeStr = timeSlot?['startTime'] ?? '00:00';
                      // Use endTime if available, otherwise just use startTime
                      final endTimeStr = timeSlot?['endTime'];

                      final formattedTime =
                          endTimeStr != null
                              ? '${_formatTime(startTimeStr)} - ${_formatTime(endTimeStr)}'
                              : _formatTime(startTimeStr);

                      return _buildTimeSlot(
                        context,
                        formattedTime,
                        subjectName,
                        roomName,
                        teacherName,
                        _getSubjectColor(subjectName),
                        isBreak:
                            entry['type'] == 'BREAK' ||
                            subjectName.toLowerCase() == 'break',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    if (time.contains(':')) {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$hour12:$minute $amPm';
    }
    return time;
  }

  Widget _buildDaySelector() => SizedBox(
    height: 60,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children:
          _dayMapping.keys.map((dayLabel) {
            final isSelected = _dayMapping[dayLabel] == _selectedDay;
            return _buildDayChip(dayLabel, isSelected);
          }).toList(),
    ),
  );

  Widget _buildDayChip(String day, bool isSelected) => GestureDetector(
    onTap: () {
      setState(() {
        _selectedDay = _dayMapping[day]!;
      });
    },
    child: Container(
      margin: const EdgeInsets.only(right: 12),
      child: Chip(
        label: Text(
          day,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            isSelected ? CustomAppColors.primary : Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        side: BorderSide.none,
      ),
    ),
  );

  Widget _buildTimeSlot(
    BuildContext context,
    String time,
    String subject,
    String room,
    String teacher,
    Color color, {
    bool isBreak = false,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width:
              90, // Increased width for longer time strings like "9:00 AM - 10:30 AM"
          child: Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12, // Slightly smaller font to fit
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isBreak ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow:
                  isBreak
                      ? []
                      : [
                        BoxShadow(
                          color: Colors.grey.shade100,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            child:
                isBreak
                    ? Center(
                      child: Text(
                        subject.toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    )
                    : Row(
                      children: [
                        Container(
                          width: 4,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    room,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.person_outline,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    teacher,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    ),
  );

  Color _getSubjectColor(String subject) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[subject.hashCode % colors.length];
  }
}
