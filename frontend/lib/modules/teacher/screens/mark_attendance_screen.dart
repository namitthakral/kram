import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/services/class_section_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_dialog.dart';
import '../../../widgets/custom_widgets/custom_elevated_button.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../models/attendance_models.dart';
import '../providers/attendance_provider.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  List<ClassInfo>? _availableClasses;
  bool _isLoadingClasses = false;

  @override
  void initState() {
    super.initState();
    // Load class sections when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClassSections();
    });
  }

  Future<void> _loadClassSections() async {
    setState(() {
      _isLoadingClasses = true;
    });

    try {
      final loginProvider = context.read<LoginProvider>();
      final teacherId = loginProvider.currentUser?.teacher?.id;

      if (teacherId == null) {
        setState(() {
          _availableClasses = [];
          _isLoadingClasses = false;
        });
        return;
      }

      final classSectionService = ClassSectionService();
      final sections = await classSectionService.getClassSections(
        teacherId: teacherId,
        status: 'ACTIVE',
      );

      final classList = <ClassInfo>[];
      for (final section in sections) {
        final sectionMap = section as Map<String, dynamic>;
        final sectionId = sectionMap['id'] as int?;
        final sectionName = sectionMap['sectionName'] as String? ?? '';
        final subject = sectionMap['subject'] as Map<String, dynamic>?;
        final course = sectionMap['course'] as Map<String, dynamic>?;
        final currentEnrollment = sectionMap['currentEnrollment'] as int? ?? 0;

        if (sectionId != null && subject != null) {
          final subjectName = subject['name'] as String? ?? 'Unknown';
          final courseId = subject['courseId'] as int? ?? 0;
          final courseName = course?['name'] as String? ?? 'Unknown';

          classList.add(
            ClassInfo(
              id: sectionId.toString(),
              name: '$courseName - $subjectName ($sectionName)',
              totalStudents: currentEnrollment,
              courseId: courseId,
              sectionName: sectionName,
              sectionId: sectionId,
            ),
          );
        }
      }

      setState(() {
        _availableClasses = classList;
        _isLoadingClasses = false;
      });
    } catch (e) {
      print('Error loading class sections: $e');
      setState(() {
        _availableClasses = [];
        _isLoadingClasses = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AttendanceProvider(),
    child: _MarkAttendanceContent(
      availableClasses: _availableClasses,
      isLoadingClasses: _isLoadingClasses,
    ),
  );
}

class _MarkAttendanceContent extends StatelessWidget {
  const _MarkAttendanceContent({
    required this.availableClasses,
    required this.isLoadingClasses,
  });

  final List<ClassInfo>? availableClasses;
  final bool isLoadingClasses;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    // Use real user data
    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');
    final userName = user?.name ?? 'Teacher';
    final designation = teacher?.designation ?? 'Teacher';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: CustomMainScreenWithAppbar(
        title: context.translate('mark_attendance'),
        appBarConfig: AppBarConfig.teacher(
          userInitials: userInitials,
          userName: userName,
          designation: designation,
          employeeId: employeeId,
          onNotificationIconPressed: () {
            // Notification handler to be implemented
          },
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Navigation Link
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: CustomAppColors.primaryBlue,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Back to Academic Management',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeSm,
                          fontWeight: AppTheme.fontWeightMedium,
                          color: CustomAppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Date & Class Row
              Row(
                children: [
                  Expanded(
                    child: _CompactDateCard(date: provider.selectedDate),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CompactClassCard(
                      selectedClass: provider.selectedClass,
                      availableClasses: availableClasses ?? [],
                      onClassSelected: provider.setSelectedClass,
                      isLoading: isLoadingClasses,
                    ),
                  ),
                ],
              ),

              if (provider.selectedClass != null) ...[
                const SizedBox(height: 16),

                // Summary Bar
                _SummaryBar(summary: provider.summary),

                const SizedBox(height: 12),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.markAllPresent,
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text(
                          'All Present',
                          style: TextStyle(fontSize: AppTheme.fontSizeXs),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomAppColors.success,
                          foregroundColor: CustomAppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: provider.markAllAbsent,
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text(
                          'All Absent',
                          style: TextStyle(fontSize: AppTheme.fontSizeXs),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomAppColors.danger,
                          side: const BorderSide(
                            color: CustomAppColors.danger,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Students List
                Text(
                  '${provider.students.length} Students',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeBase,
                    fontWeight: AppTheme.fontWeightBold,
                    color: CustomAppColors.slate800,
                  ),
                ),
                const SizedBox(height: 10),
              ],

              if (provider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.selectedClass == null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.class_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Select a class to begin',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeBase,
                            color: CustomAppColors.slate600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...provider.students.map(
                  (student) => _StudentCard(
                    student: student,
                    onToggle:
                        () => provider.toggleStudentAttendance(student.id),
                  ),
                ),

              const SizedBox(height: 8),
              CustomElevatedButton(
                text: 'Save Changes',
                onPressed: () async {
                  final teacherUuid = user?.uuid;
                  final teacherId = teacher?.id;

                  if (teacherUuid == null || teacherId == null) {
                    showCustomSnackbar(
                      message: 'Unable to identify teacher',
                      type: SnackbarType.warning,
                    );
                    return;
                  }

                  final success = await provider.saveAttendance(
                    teacherUuid,
                    teacherId,
                  );

                  if (context.mounted) {
                    if (success) {
                      showCustomSnackbar(
                        message: 'Attendance saved successfully',
                        type: SnackbarType.success,
                      );
                      Navigator.pop(context);
                    } else {
                      showCustomSnackbar(
                        message: provider.error ?? 'Failed to save',
                        type: SnackbarType.warning,
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // floatingActionButtonWidget:
        //     provider.selectedClass != null
        //         ? FloatingActionButton.extended(
        //           onPressed: () async {
        //             final success = await provider.saveAttendance();
        //             if (context.mounted) {
        //               if (success) {
        //                 ScaffoldMessenger.of(context).showSnackBar(
        //                   const SnackBar(
        //                     content: Text('✓ Attendance saved successfully'),
        //                     backgroundColor: Color(0xFF10b981),
        //                   ),
        //                 );
        //                 Navigator.pop(context);
        //               } else {
        //                 ScaffoldMessenger.of(context).showSnackBar(
        //                   SnackBar(
        //                     content: Text(provider.error ?? 'Failed to save'),
        //                     backgroundColor: const Color(0xFFef4444),
        //                   ),
        //                 );
        //               }
        //             }
        //           },
        //           icon:
        //               provider.isLoading
        //                   ? const SizedBox(
        //                     width: 20,
        //                     height: 20,
        //                     child: CircularProgressIndicator(
        //                       color: Colors.white,
        //                       strokeWidth: 2,
        //                     ),
        //                   )
        //                   : const Icon(Icons.save_rounded),
        //           label: Text(
        //             provider.isLoading ? 'Saving...' : 'Save Attendance',
        //           ),
        //           backgroundColor: const Color(0xFF155dfc),
        //         )
        //         : null,
      ),
    );
  }
}

// Compact Date Card
class _CompactDateCard extends StatelessWidget {
  const _CompactDateCard({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: CustomAppColors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: CustomAppColors.black01.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: CustomAppColors.slate600,
            ),
            SizedBox(width: 4),
            Text(
              'Date',
              style: TextStyle(
                fontSize: 11,
                color: CustomAppColors.slate600,
                fontWeight: AppTheme.fontWeightMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('MMM dd').format(date),
          style: const TextStyle(
            fontSize: AppTheme.fontSizeLg,
            fontWeight: AppTheme.fontWeightBold,
            color: CustomAppColors.slate800,
          ),
        ),
        Text(
          DateFormat('EEEE').format(date),
          style: const TextStyle(fontSize: 11, color: CustomAppColors.slate600),
        ),
      ],
    ),
  );
}

// Compact Class Card
class _CompactClassCard extends StatelessWidget {
  const _CompactClassCard({
    required this.selectedClass,
    required this.availableClasses,
    required this.onClassSelected,
    this.isLoading = false,
  });

  final ClassInfo? selectedClass;
  final List<ClassInfo> availableClasses;
  final ValueChanged<ClassInfo> onClassSelected;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => _showClassPicker(context),
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CustomAppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              selectedClass != null
                  ? CustomAppColors.primaryBlue
                  : CustomAppColors.slate200,
          width: selectedClass != null ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CustomAppColors.black01.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.class_, size: 14, color: CustomAppColors.slate600),
              SizedBox(width: 4),
              Text(
                'Class',
                style: TextStyle(
                  fontSize: 11,
                  color: CustomAppColors.slate600,
                  fontWeight: AppTheme.fontWeightMedium,
                ),
              ),
              Spacer(),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: CustomAppColors.slate400,
              ),
            ],
          ),
          const SizedBox(height: 4),
          isLoading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CustomAppColors.primaryBlue,
                ),
              )
              : Text(
                selectedClass?.name ?? 'Select',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLg,
                  fontWeight: AppTheme.fontWeightBold,
                  color:
                      selectedClass != null
                          ? CustomAppColors.slate800
                          : CustomAppColors.slate400,
                ),
              ),
          if (selectedClass != null && !isLoading)
            Text(
              '${selectedClass!.totalStudents} students',
              style: const TextStyle(
                fontSize: 11,
                color: CustomAppColors.slate600,
              ),
            ),
        ],
      ),
    ),
  );

  Future<void> _showClassPicker(BuildContext context) async {
    final selectedClassInfo = await CustomDialog.showSelection<ClassInfo>(
      context: context,
      title: 'Select Class',
      subtitle: 'Choose a class to mark attendance',
      headerIcon: Icons.class_,
      selectedValue: selectedClass,
      items:
          availableClasses
              .map(
                (classInfo) => SelectionItem<ClassInfo>(
                  value: classInfo,
                  label: classInfo.name,
                  subtitle: '${classInfo.totalStudents} students enrolled',
                  icon: Icons.school,
                ),
              )
              .toList(),
    );

    if (selectedClassInfo != null) {
      onClassSelected(selectedClassInfo);
    }
  }
}

// Summary Bar
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.summary});

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        _SummaryItem(
          icon: Icons.groups,
          label: 'Total',
          value: '${summary.totalStudents}',
          color: CustomAppColors.blue500,
        ),
        const SizedBox(width: 16),
        _SummaryItem(
          icon: Icons.check_circle,
          label: 'Present',
          value: '${summary.present}',
          color: CustomAppColors.success,
        ),
        const SizedBox(width: 16),
        _SummaryItem(
          icon: Icons.cancel,
          label: 'Absent',
          value: '${summary.absent}',
          color: CustomAppColors.danger,
        ),
      ],
    ),
  );
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: CustomAppColors.slate600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: AppTheme.fontSizeBase,
                fontWeight: AppTheme.fontWeightBold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Student Card
class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student, required this.onToggle});

  final StudentAttendance student;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isPresent = student.status == AttendanceStatus.present;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: CustomAppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isPresent
                  ? CustomAppColors.success.withValues(alpha: 0.3)
                  : CustomAppColors.danger.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: CustomAppColors.black01.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isPresent
                              ? [
                                CustomAppColors.success,
                                const Color(0xFF059669),
                              ]
                              : [
                                CustomAppColors.danger,
                                const Color(0xFFdc2626),
                              ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      student.initials,
                      style: const TextStyle(
                        color: CustomAppColors.white,
                        fontSize: AppTheme.fontSizeBase,
                        fontWeight: AppTheme.fontWeightBold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name
                Expanded(
                  child: Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: AppTheme.fontWeightSemibold,
                      color: CustomAppColors.slate800,
                    ),
                  ),
                ),

                // Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isPresent
                            ? CustomAppColors.success.withValues(alpha: 0.1)
                            : CustomAppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPresent ? Icons.check_circle : Icons.cancel,
                        color:
                            isPresent
                                ? CustomAppColors.success
                                : CustomAppColors.danger,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isPresent ? 'Present' : 'Absent',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeXs,
                          fontWeight: AppTheme.fontWeightSemibold,
                          color:
                              isPresent
                                  ? CustomAppColors.success
                                  : CustomAppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
