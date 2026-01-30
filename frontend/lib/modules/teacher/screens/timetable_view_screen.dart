import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
// import '../providers/timetable_provider.dart';

class TimetableViewScreen extends StatefulWidget {
  const TimetableViewScreen({super.key});

  @override
  State<TimetableViewScreen> createState() => _TimetableViewScreenState();
}

class _TimetableViewScreenState extends State<TimetableViewScreen> {
  bool _isLoading = true;
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  // Unused field removed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final loginProvider = context.read<LoginProvider>();
      // final timetableProvider = context.read<TimetableProvider>();
      final user = loginProvider.currentUser;
      final institutionId = user?.teacher?.institutionId;

      if (institutionId != null) {
        // Load time slots and timetable data
        // For view only, we might need a specific getTimetable(classId) or similar
        // Or if this is "My Timetable", we fetch by teacherId.
        // Assuming we are viewing the logged-in teacher's timetable effectively
        // Since `TimetableTemplateScreen` seems to be the editor for a specific class,
        // Let's assume this screen shows the TEACHER'S comprehensive timetable?
        // OR is this viewing a specific class's timetable?
        // Based on `TimetablesListScreen` navigation, we clicked a Class to get here.
        // So we should be viewing THAT class's timetable.

        // Wait, the router doesn't pass classId yet. I need to update Router to pass it.
        // For now, I'll build the generic structure and rely on Provider or State.
        // But `TimetableTemplateScreen` loads everything fresh.

        // Let's Mock for now to establish UI, then wire up.
        await Future.delayed(const Duration(seconds: 1)); // Mock delay
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We need to know WHICH class we are viewing.
    // Ideally passed via constructor/route params.
    // For now, I'll just use a placeholder title.
    const className = "Class Timetable";

    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;

    return CustomMainScreenWithAppbar(
      title: className,
      appBarConfig: AppBarConfig.teacher(
        userInitials: user?.name?.substring(0, 1) ?? 'T',
        userName: user?.name ?? 'Teacher',
        designation: user?.teacher?.designation ?? 'Teacher',
        employeeId: user?.teacher?.employeeId ?? 'EMP',
        onNotificationIconPressed: () {},
      ),
      bottomWidget: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigation to Edit/Template screen
              context.pushNamed('create_timetable');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomAppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit_calendar_rounded, color: Colors.white),
            label: const Text(
              'Manage Timetable',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: AppTheme.fontWeightBold,
              ),
            ),
          ),
        ),
      ),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegend(),
                    const SizedBox(height: 16),
                    ..._days.map((day) => _buildDaySchedule(day)),
                  ],
                ),
              ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem(
          'Lecture',
          CustomAppColors.blue500.withOpacity(0.1),
          CustomAppColors.blue500,
        ),
        const SizedBox(width: 12),
        _legendItem('Break', Colors.orange.withOpacity(0.1), Colors.orange),
      ],
    );
  }

  Widget _legendItem(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDaySchedule(String day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CustomAppColors.slate800,
              ),
            ),
          ),
          const Divider(height: 1),
          // Mock Slots for Visualization
          _buildSlot('09:00 - 10:00', 'Mathematics', 'Class 10-A'),
          _buildSlot('10:00 - 11:00', 'Physics', 'Class 10-A'),
          _buildSlot('11:00 - 11:30', 'Break', '', isBreak: true),
          _buildSlot('11:30 - 12:30', 'Chemistry', 'Class 10-A'),
        ],
      ),
    );
  }

  Widget _buildSlot(
    String time,
    String subject,
    String subtext, {
    bool isBreak = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        color: isBreak ? Colors.orange.withOpacity(0.05) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isBreak
                      ? Colors.orange.withOpacity(0.1)
                      : CustomAppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isBreak ? Colors.orange : CustomAppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isBreak ? Colors.orange : CustomAppColors.slate800,
                  ),
                ),
                if (subtext.isNotEmpty)
                  Text(
                    subtext,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CustomAppColors.slate500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
