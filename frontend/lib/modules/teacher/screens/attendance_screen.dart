import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../utils/custom_snackbar.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_dialog.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../models/attendance_models.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_history_tab.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AttendanceProvider(),
    child: const _AttendanceScreenContent(),
  );
}

class _AttendanceScreenContent extends StatefulWidget {
  const _AttendanceScreenContent();

  @override
  State<_AttendanceScreenContent> createState() =>
      _AttendanceScreenContentState();
}

class _AttendanceScreenContentState extends State<_AttendanceScreenContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginProvider = context.read<LoginProvider>();
      final userUuid = loginProvider.currentUser?.uuid;
      if (userUuid != null) {
        context.read<AttendanceProvider>().loadInitialData(userUuid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');
    final userName = user?.name ?? 'Teacher';
    final designation = teacher?.designation ?? 'Faculty';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return DefaultTabController(
      length: 2,
      child: CustomMainScreenWithAppbar(
        title: 'Attendance',
        appBarConfig: AppBarConfig.teacher(
          userInitials: userInitials,
          userName: userName,
          designation: designation,
          employeeId: employeeId,
          onNotificationIconPressed: () {},
        ),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: CustomAppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: CustomAppColors.primary,
                tabs: [
                  Tab(
                    text: 'Today\'s Overview',
                  ), // Renamed from Mark Attendance to match user screenshot intent
                  Tab(text: 'History'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [_MarkAttendanceTab(), AttendanceHistoryTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarkAttendanceTab extends StatelessWidget {
  const _MarkAttendanceTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    return Column(
      children: [
        // Header / Class Selector
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _showClassPicker(context, provider),
                child: Row(
                  children: [
                    Text(
                      provider.selectedClass?.name ?? 'Select Class',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: CustomAppColors.primary,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showDatePicker(context, provider),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(provider.selectedDate),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Student List
        Expanded(
          child:
              provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.selectedClass == null
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Select a class to mark attendance',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : provider.students.isEmpty
                  ? const Center(child: Text('No students found'))
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.students.length,
                    itemBuilder:
                        (context, index) => _buildStudentAttendanceRow(
                          provider.students[index],
                          provider,
                        ),
                  ),
        ),

        // Actions
        if (provider.selectedClass != null && !provider.isLoading)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed:
                  () => _saveAttendance(
                    context,
                    provider,
                    teacher?.id,
                    user?.uuid,
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomAppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Attendance',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStudentAttendanceRow(
    StudentAttendance student,
    AttendanceProvider provider,
  ) {
    final isPresent = student.status == AttendanceStatus.present;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isPresent
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
          child: Text(
            student.initials,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPresent ? Colors.green : Colors.red,
            ),
          ),
        ),
        title: Text(student.name),
        // subtitle: Text('ID: ${student.id}'),
        trailing: Switch(
          value: isPresent,
          activeColor: Colors.green,
          inactiveThumbColor: Colors.red,
          inactiveTrackColor: Colors.red.withOpacity(0.3),
          onChanged: (val) => provider.toggleStudentAttendance(student.id),
        ),
      ),
    );
  }

  Future<void> _showClassPicker(
    BuildContext context,
    AttendanceProvider provider,
  ) async {
    final selectedClass = await CustomDialog.showSelection<ClassInfo>(
      context: context,
      title: 'Select Class',
      subtitle: 'Choose class to mark attendance',
      headerIcon: Icons.class_,
      selectedValue: provider.selectedClass,
      items:
          provider.availableClasses
              .map(
                (c) => SelectionItem(
                  value: c,
                  label: c.name,
                  subtitle: '${c.totalStudents} Students',
                  icon: Icons.school,
                ),
              )
              .toList(),
    );

    if (selectedClass != null) {
      provider.setSelectedClass(selectedClass);
    }
  }

  Future<void> _showDatePicker(
    BuildContext context,
    AttendanceProvider provider,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      provider.setSelectedDate(date);
    }
  }

  Future<void> _saveAttendance(
    BuildContext context,
    AttendanceProvider provider,
    int? teacherId,
    String? userUuid,
  ) async {
    if (teacherId == null || userUuid == null) {
      showCustomSnackbar(
        message: 'Error: User information missing',
        type: SnackbarType.error,
      );
      return;
    }

    final success = await provider.saveAttendance(userUuid, teacherId);
    if (context.mounted) {
      if (success) {
        showCustomSnackbar(
          message: 'Attendance saved successfully',
          type: SnackbarType.success,
        );
      } else {
        showCustomSnackbar(
          message: provider.error ?? 'Failed to save attendance',
          type: SnackbarType.error,
        );
      }
    }
  }
}
