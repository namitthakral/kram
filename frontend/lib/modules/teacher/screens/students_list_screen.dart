import 'package:flutter/material.dart';

import '../../../../core/services/class_section_service.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({
    required this.className,
    required this.sectionId,
    super.key,
  });
  final String className;
  final int sectionId;

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  late Future<Map<String, dynamic>> _studentsFuture;
  final ClassSectionService _classSectionService = ClassSectionService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _studentsFuture = _classSectionService.getEnrolledStudents(
      sectionId: widget.sectionId,
    );
  }

  @override
  Widget build(BuildContext context) => CustomMainScreenWithAppbar(
      title: 'Students - ${widget.className}',
      appBarConfig: AppBarConfig.teacher(
        userInitials: 'T',
        userName: 'Teacher',
        designation: 'Faculty',
        employeeId: 'EMP-001',
        onNotificationIconPressed: () {},
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(_loadData);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final responseData = snapshot.data;
          // Backend returns { success: true, data: { section: {...}, students: [...], count: N } }
          final data = responseData?['data'] as Map<String, dynamic>?;
          final students = data?['students'] as List<dynamic>? ?? [];

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 24),
                  const Text(
                    'No students enrolled',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1e293b),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This class section has no enrolled students yet',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final student = students[index] as Map<String, dynamic>;
              final name = student['name'] as String? ?? 'Unknown';
              final rollNumber = student['rollNumber'] as String? ?? 'N/A';
              final admissionNumber =
                  student['admissionNumber'] as String? ?? '';
              final initials = UserUtils.getInitials(name);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: CustomAppColors.primary.withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    initials,
                    style: const TextStyle(color: CustomAppColors.primary),
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (rollNumber != 'N/A') Text('Roll No: $rollNumber'),
                    if (admissionNumber.isNotEmpty)
                      Text('Admission No: $admissionNumber'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    // TODO: Show student details
                  },
                ),
              );
            },
          );
        },
      ),
    );
}
