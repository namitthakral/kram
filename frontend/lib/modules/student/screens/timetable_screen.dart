import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginProvider>().currentUser;
    final userInitials = user != null ? UserUtils.getInitials(user.name) : 'ST';
    final userName = user?.name ?? 'Student';
    final grade = user?.student?.gradeLevel ?? 'Class 10';
    final rollNumber = user?.student?.rollNumber ?? '23';

    return CustomMainScreenWithAppbar(
      title: 'Timetable',
      appBarConfig: AppBarConfig.student(
        userInitials: userInitials,
        userName: userName,
        grade: grade,
        rollNumber: rollNumber,
        onNotificationIconPressed: () {},
      ),
      child: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTimeSlot(context, '09:00 AM', 'Mathematics', 'Room 101', 'Mr. Roberts', Colors.blue),
                _buildTimeSlot(context, '10:00 AM', 'Physics', 'Lab 2', 'Ms. Davis', Colors.orange),
                _buildTimeSlot(context, '11:00 AM', 'Break', '', '', Colors.grey, isBreak: true),
                _buildTimeSlot(context, '11:30 AM', 'Computer Science', 'Comp Lab', 'Mr. Wilson', Colors.purple),
                _buildTimeSlot(context, '12:30 PM', 'English', 'Room 101', 'Mrs. Smith', Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() => SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _buildDayChip('Mon', true),
          _buildDayChip('Tue', false),
          _buildDayChip('Wed', false),
          _buildDayChip('Thu', false),
          _buildDayChip('Fri', false),
        ],
      ),
    );

  Widget _buildDayChip(String day, bool isSelected) => Container(
      margin: const EdgeInsets.only(right: 12),
      child: Chip(
        label: Text(
          day,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isSelected ? CustomAppColors.primary : Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        side: BorderSide.none,
      ),
    );

  Widget _buildTimeSlot(
      BuildContext context, String time, String subject, String room, String teacher, Color color,
      {bool isBreak = false}) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
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
                boxShadow: isBreak
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.grey.shade100,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: isBreak
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
                          height: 40,
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
                                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    room,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
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
}
